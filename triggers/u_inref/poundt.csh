#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test verifies that ^#t is inaccessible from within the GT.M runtime as well as database
# extracts.  The corollary is that ^#t in extracts will not be loaded by MUPIP
#
# This test first makes some generic extracts and mangles the GLO and ZWR ones.
#
# 1. Load a mangled ZWR extract
#    add triggers
#    use ^%GD to search for ^#t records
#    verify no triggers in the extract
#
# 2. [not for unicode] load a GLO extract
#    add triggers
#    use ^%GD to search for ^#t records
#    verify no triggers in the extract
#
# 3. load a binary extract
#    add triggers
#    use ^%GD to search for ^#t records
#    verify no triggers in the extract
#
# 4 and 5 back and restore DB
#    add triggers
#    use ^%GD to search for ^#t records
#    verify no triggers in the extract
#
# 6. $reference showed ^#t records during testing
#    This part was added to verify that $reference and ^() don't reveal ^#t


# gtm_chset can be randomly chosen to be either "M" or "UTF-8" or undefined. If undefined, then
# set it to M mode. Not doing so will cause the "$gtm_chset" expression below to error out with
# "gtm_chset: undefined variable". Though it would be good to randomize between M and UTF-8 in
# such "undefined" cases, it is okay to force set to "M" as the UTF-8 option will anyways be
# tested.
if !($?gtm_chset) $switch_chset "M" >&! switch_chset

# This test relies on the default region configuration, disable spanning regions
setenv gtm_test_spanreg 0

setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1

echo "Making some extracts"
# create some data
$gtm_exe/mumps -run %XCMD 'for i=1:1:10 set ^a(i)=i,^b(i*2)=i*2,^c(i*5)=i*3'

if ("M" == "$gtm_chset") then
	$MUPIP extract -format=go -nolog orig_poundt.glo
else
	# UTF-8 mode, add some unicode data
	$gtm_exe/mumps -run %XCMD 'set ^a(101)=$char(2801)'
	$gtm_exe/mumps -run %XCMD 'for i=2406:1:2415 set $piece(^b(i),$increment(j))=$char(i)'
endif
$MUPIP extract -format=zwr -nolog orig_poundt.zwr
$MUPIP extract -format=bin -nolog orig_poundt.bin

# mangle the ZWR extract ith ^#t records
cat >> orig_poundt.zwr << EOF
^#t("c","#LABEL")="1"
^#t("c","#CYCLE")="1"
^#t("c","#COUNT")="1"
^#t("c",1,"TRIGNAME")="c#1#"
^#t("c",1,"CMD")="K"
^#t("c",1,"XECUTE")="kill ^b set ^b=76 write \$ztrig,\$c(9),\$reference,!"
^b="1||3||5||7||9||11||13||15||17||19"
^c="42"
EOF

# mangle the GLO extract with ^#t records, irrelevant in UTF-8 mode
cat >> orig_poundt.glo << EOF
^#t("c","#LABEL")="2"
^#t("c","#CYCLE")="2"
^#t("c","#COUNT")="2"
^#t("c",2,"TRIGNAME")="c#2#"
^#t("c",2,"CMD")="K"
^#t("c",2,"XECUTE")="kill ^b set ^b=76 write \$ztrig,\$c(9),\$reference,!"
^b
1||3||5||7||9||11||13||15||17||19
^c
42
EOF

$gtm_tst/com/dbcheck.csh -extract
$echoline
$echoline

cat > poundt.trg << TFILE
; SET
+^a(:) -command=S,K -xecute="write \$ztri,\$char(9),\$reference,!"
+^b(:) -command=S,K -xecute="write \$ztri,\$char(9),\$reference,!"
+^c(:) -command=S,K -xecute="write \$ztri,\$char(9),\$reference,!"
TFILE
# Heads UP, this setenv will load the trigger file at each dbcreate!
setenv test_specific_trig_file `pwd`/"poundt.trg"

echo "No triggers should fire during MUPIP LOAD"
echo ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
echo "1. ZWR"
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 3

(echo "" ; echo "") | $gtm_exe/mumps -run ^%GD
$MUPIP set -journal=enable,nobefore -reg "*" >&! start.zwr.jnllog

$MUPIP load -format=zwr orig_poundt.zwr
(echo "" ; echo "") | $gtm_exe/mumps -run ^%GD

# show that ^#t is not in the extracts
$MUPIP extract -format=zwr -nolog poundt.zwr
$grep "\^#t" poundt.zwr
# show that ^#t is not in the journal files
foreach db (*.mjl)
	$MUPIP journal -extract -noverify -forward -fences=none ${db} >>&! zwr.extract
	set mjf=`echo $db | sed 's/\.mjl/\.mjf/'`
	$grep '\^#t' $mjf
	mv $mjf ${mjf}.zwr
end

$gtm_tst/com/dbcheck.csh -extract

if ("M" == "$gtm_chset") then
	echo ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
	echo "2. GLO"
	setenv gtm_test_sprgde_id "ID3"	# to differentiate multiple dbcreates done in the same subtest
	$gtm_tst/com/dbcreate.csh mumps 3

	(echo "" ; echo "") | $gtm_exe/mumps -run ^%GD
	$MUPIP set -journal=enable,nobefore -reg "*" >&! start.glo.jnllog

	$MUPIP load -format=go orig_poundt.glo
	(echo "" ; echo "") | $gtm_exe/mumps -run ^%GD

	# show that ^#t is not in the extracts
	$MUPIP extract -format=go -nolog poundt.glo
	$grep "\^#t" poundt.glo
	# show that ^#t is not in the journal files
	foreach db (*.mjl)
		$MUPIP journal -extract -noverify -forward -fences=none ${db} >>&! glo.extract
		set mjf=`echo $db | sed 's/\.mjl/\.mjf/'`
		$grep '\^#t' $mjf
		mv $mjf ${mjf}.glo
	end

	$gtm_tst/com/dbcheck.csh -extract
endif

echo ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
echo "3. BIN"
setenv gtm_test_sprgde_id "ID4"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 3

(echo "" ; echo "") | $gtm_exe/mumps -run ^%GD
$MUPIP set -journal=enable,nobefore -reg "*" >&! start.bin.jnllog

$MUPIP load -format=bin orig_poundt.bin
(echo "" ; echo "") | $gtm_exe/mumps -run ^%GD

# show that ^#t is not in the extracts
$MUPIP extract -format=bin -nolog poundt.bin
strings poundt.bin | $grep "\^#t"
# show that ^#t is not in the journal files
foreach db (*.mjl)
	$MUPIP journal -extract -noverify -forward -fences=none ${db} >>&! bin.extract
	set mjf=`echo $db | sed 's/\.mjl/\.mjf/'`
	$grep '\^#t' $mjf
	mv $mjf ${mjf}.bin
end

echo "Cannot see ^#t from GT.M runtime"
(echo "#t" ; echo "") | $gtm_exe/mumps -run ^%GD

$GTM << GTM |& uniq
set \$ZPROMPT=""
do ^%GD
#t


GTM

$GTM << GTM |& uniq
set \$ZPROMPT=""
set a="^#t"
zwr ^#t
zwr @a
xecute @a
GTM

$GTM << GTM |& uniq
set \$ZPROMPT=""
set a="^#t(""a"",""#LABEL"")"
set ^#t("a","#LABEL")=0
set @a=42
xecute @a
xecute "set @a"
GTM

echo "# DSE should be able to access ^#t records"
$DSE << dse_eof >>&! dse_find_key.out
find -key="^#t"
find -key="^#t(""a"",1,""BHASH"")"
find -key="^#t(""a"",1,""TRIGNAME"")"
find -key="^#t(""a"",""#LABEL"")"
find -key="^#t(""a"")
find -key="^#t(""c"",""#CYCLE"")"
find -region=DEFAULT
find -key="^#t(""c"",""#CYCLE"")"
dse_eof

echo "" >>&! dse_find_key.out
sed 's/3:.*,/3:XX,/' dse_find_key.out

echo "# dump of the right blocks should show ^#t records"
$DSE dump -block=2 >&! dse_dump_block.out
$DSE dump -block=3 >>&! dse_dump_block.out
$grep 'Key' dse_dump_block.out | sed 's/Off.*Key/##MASKED## Key/'

$DSE << dse_eof >>&! dse_dump_records.out
dump -block=3 -rec=6
dump -block=3 -rec=7
dse_eof

echo ""
echo "Added for GTM2168 do not adjust the TEST_AWKs"
$grep -v " : | " dse_dump_records.out | sed 's/Off.*Key/##MASKED## Key/'

$gtm_tst/com/dbcheck.csh -extract

echo ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
echo "4. Backup"
unsetenv test_specific_trig_file
setenv gtm_test_sprgde_id "ID5"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1
mkdir -p restore
# Create journal files for BACKUP/RESTORE testing
$MUPIP set -journal=enable,nobefore -reg "*" >&! jnl_output.out

cat > updates.trg << TFILE
-*
+^y -command=S -xecute="set ^r(\$ztvalue)=\$reference" -name=why
+^z -command=S -xecute="set \$ztvalue=\$ztvalue/3 set ^r(\$ztvalue)=\$reference" -name=zreason
TFILE
$load updates.trg -noprompt
$show

# multiple use M routine for checking data in the DB
cat > datatest.m << MPROG
	if \$data(^r) zwr ^r
	if \$data(^y) zwr ^y
	if \$data(^x) zwr ^x
	if \$data(^z) zwr ^z
MPROG
$convert_to_gtm_chset datatest.m

# make a comprehensive backup
echo "comprehensive backup"
$MUPIP backup -database DEFAULT restore/mumps.dat >&! complete.bkup

# load some more triggers to allow for an extra transaction after backup is restored
cat > updates2.trg << TFILE
+^y -command=K -xecute="set ^r(\$ztvalue)=\$reference" -name=why
+^z -command=K -xecute="set \$ztvalue=\$ztvalue/3 set ^r(\$ztvalue)=\$reference" -name=zreason
TFILE
$load updates2.trg
$show
# trap the trigger addition transaction so that we can replace these triggers with another set
$MUPIP backup -bytestream -since=bytestream DEFAULT restore/mumps.i0 >&! incremental.i0

$GTM << GTM |& uniq
set \$ZPROMPT=""
write "Do some updates",!
set ^y=90
set ^x="^y"
set ^z=@^x
GTM
$MUPIP backup -bytestream -since=bytestream DEFAULT restore/mumps.i1 >&! incremental.i1

$GTM << GTM |& uniq
set \$ZPROMPT=""
write "Do some more updates",!
set ^y=90
for i=95:1:99 set ^y=i,^z=@^x
write "Should see updates to ^r",!
do ^%GD

GTM
$gtm_exe/mumps -run datatest
$MUPIP backup -bytestream -since=bytestream DEFAULT restore/mumps.i2 >&! incremental.i2

echo ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
echo "5. Restore"

mv mumps.dat mumps.dat.bak
$MUPIP create 	# Create fresh database to be restored with the incremental backups

echo ""
$echoline
echo "First incremental restore"
$echoline
$MUPIP restore mumps.dat restore/mumps.i0
echo ""

$echoline
echo "Second incremental restore"
$echoline
$MUPIP restore mumps.dat restore/mumps.i1

echo "After second incremental restore"
$gtm_exe/mumps -run datatest

$echoline
echo "Final incremental restore"
$echoline
$MUPIP restore mumps.dat restore/mumps.i2

echo "After Final incremental restore"
$gtm_exe/mumps -run datatest

# Temporarily disable on the fly trigger upgrade testing
# Save current value and use that to restore the env var instead of restoring it always to 1
# since it is possible the env var is 0 coming into this script (e.g. on ARM where gtm_test_nopriorgtmver is set)
if ($?gtm_test_trig_upgrade) then
	set save_trig_upgrade = $gtm_test_trig_upgrade
endif
unsetenv gtm_test_trig_upgrade
$gtm_tst/com/dbcheck.csh -extract
if ($?save_trig_upgrade) then
	setenv gtm_test_trig_upgrade $save_trig_upgrade
endif

echo ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
echo "6. ZTrigger"
setenv gtm_test_sprgde_id "ID6"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 3

$echoline
echo "Test dollar reference at runtime startup and with nothing in select"
$GTM << GTM |& uniq
set \$ZPROMPT=""
write "\$R at runtime startup is "_\$select(\$reference="":"valid",1:"invalid."_\$reference),!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SELECT naked
set x=\$ztrigger("select")
write "\$R on naked select is ",\$select(\$reference="":"valid",1:"invalid."_\$reference),!

set ^cmd="select"
set ^noid="dominos"
set x=\$ztrigger(^cmd)
write "\$R on naked select with GVN parm is ",\$select(\$reference="^cmd":"valid",1:"invalid."_\$reference),!
GTM

$echoline
echo "Test dollar reference with ztrigger FILE commands"
$GTM << GTM |& uniq
set \$ZPROMPT=""
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FILE
set x=\$ztrigger("file","poundt.trg")
write "\$R after FILE is ",\$select(\$reference="":"valid",1:"invalid."_\$reference),!
write ^("TRIGNAME"),!

set ^cmd="FILE"
set ^trig="poundt.trg"
set ^noid="dominos"

set x=\$ztrigger(^cmd,"poundt.trg")
write "\$R after FILE with GVN parm is ",\$select(\$reference="^cmd":"valid",1:"invalid."_\$reference),!

set x=\$ztrigger(^cmd,^trig)
write "\$R after FILE with GVN parm is ",\$select(\$reference="^trig":"valid",1:"invalid."_\$reference),!

set x=\$ztrigger("File",^trig)
write "\$R after FILE with GVN parm is ",\$select(\$reference="^trig":"valid",1:"invalid."_\$reference),!
GTM

$echoline
echo "Test dollar reference with ztrigger SELECT commands"
$GTM << GTM |& uniq
set \$ZPROMPT=""
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SELECT
set x=\$ztrigger("select","^c")
write "\$R after select is ",\$select(\$reference="":"valid",1:"invalid."_\$reference),!
write ^("TRIGNAME"),!

set x=\$ztrigger("select")
write "\$R after select is ",\$select(\$reference="":"valid",1:"invalid."_\$reference),!
write ^("TRIGNAME"),!

set ^cmd="Select"
set ^trig="^a"
set ^noid="dominos"

set x=\$ztrigger(^cmd)
write "\$R after select with GVN parm is ",\$select(\$reference="^cmd":"valid",1:"invalid."_\$reference),!

set x=\$ztrigger("select",^trig)
write "\$R after select with GVN parm is ",\$select(\$reference="^trig":"valid",1:"invalid."_\$reference),!

set x=\$ztrigger(^cmd,"b*")
write "\$R after select with GVN parm is ",\$select(\$reference="^cmd":"valid",1:"invalid."_\$reference),!

set x=\$ztrigger(^cmd,^trig)
write "\$R after select with GVN parm is ",\$select(\$reference="^trig":"valid",1:"invalid."_\$reference),!
GTM

$echoline
echo "Test dollar reference with ztrigger ITEM commands"
$GTM << GTM |& uniq
set \$ZPROMPT=""
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ITEM
set x=\$ztrigger("item","+^z(:) -command=ZK -xecute=""write \$ztri,\$char(9),\$reference,!"" ")
write "\$R after ITEM add is ",\$select(\$reference="":"valid",1:"invalid."_\$reference),!
write ^("TRIGNAME"),!

set ^cmd="item"
set ^trig="+^z(:) -command=S,K -xecute=""write \$ztri,\$char(9),\$reference,!"" "
set ^noid="dominos"

set x=\$ztrigger("item",^trig)
write "\$R after ITEM add with GVN is ",\$select(\$reference="^trig":"valid",1:"invalid."_\$reference),!

set x=\$ztrigger(^cmd,^trig)
write "\$R after ITEM add with GVN is ",\$select(\$reference="^trig":"valid",1:"invalid."_\$reference),!

set x=\$ztrigger(^cmd,"-^z(:) -command=S -xecute=""write \$ztri,\$char(9),\$reference,!"" ")
write "\$R after ITEM add with GVN is ",\$select(\$reference="^cmd":"valid",1:"invalid."_\$reference),!
GTM

echo ""
$GTM << GTM |& uniq
set \$ZPROMPT=""
set x=\$ztrigger("item","-^DONOTEXIST(:) -command=S,K -xecute=""write \$ztri,\$char(9),\$reference,!"" ")
write "\$R after deleting trigger is ",\$select(\$reference="":"valid",1:"invalid."_\$reference),!
write ^("TRIGNAME"),!

set x=\$ztrigger("item","-^b(:) -command=K -xecute=""write \$ztri,\$char(9),\$reference,!"" ")
write "\$R after deleting trigger is ",\$select(\$reference="":"valid",1:"invalid."_\$reference),!
write ^("TRIGNAME"),!

set x=\$ztrigger("item","-*")
write "\$R after deleting all triggers is ",\$select(\$reference="":"valid",1:"invalid."_\$reference),!
GTM

$gtm_tst/com/dbcheck.csh -extract

echo "# Lift restriction on DSE that prevents changing ^#t by key"
setenv gtm_test_sprgde_id "ID7"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1

echo '+^b -commands=S -xecute="do ^badtrg"' >&! t.trg
echo '-*' >&! del.trg
cat >&! goodtrg.m << CAT_EOF
goodtrg	;
	set ^a=^b
	quit
CAT_EOF

echo "# Install a simple trigger in the database and dump the block containing ^#t records"
$MUPIP trigger -trig=t.trg >&! changepoundt_add_trigger.out
$DSE >&! changepoundt_dse.out << DSE_EOF
open -file=block3.zwr
dump -block=3 -zwr
close
exit
DSE_EOF

echo "# Print the original trigger detail"
$MUPIP trigger -select originaltrigger.trg
cat originaltrigger.trg

echo "# Delete the installed trigger"
$MUPIP trigger -trig=del.trg -noprompt >&! changepoundt_del_trigger.out

echo "# Create add record commands from the extracted block details"
$DSE dump -bl=3 >&! changepoundt_dump_bl3.out
set recs = `$grep -c 'Rec:' changepoundt_dump_bl3.out`
while ($recs)
	$DSE remove -block=3 -rec=1 >>&! changepoundt_remove_bl3.out
	@ recs--
end

echo '$DSE >&! dse_add.out << DSE_EOF' >&! changepoundt_add_record.csh
echo 'change -bl=5 -bs=10' >>&! changepoundt_add_record.csh
$tail -n +3 block3.zwr | $tst_awk -F = '{k=$1;v=$2;s=gsub("\"","\"\"",k); printf "add -bl=5 -r=%x -key=\"%s\" -data=%s\n",NR,k,v}'  >>&! changepoundt_add_record.csh
echo 'DSE_EOF' >>&! changepoundt_add_record.csh

mv changepoundt_add_record.csh changepoundt_add_record.csh.bak
sed 's/"_\$C/"_\\\$C/;s/badtrg/goodtrg/' changepoundt_add_record.csh.bak >>&! changepoundt_add_record.csh

echo "# dse add records to recreate trigger insertion"
source changepoundt_add_record.csh

echo "# Print the trigger detail after inserting records via dse"
$MUPIP trigger -select dseaddedtrigger.trg
cat dseaddedtrigger.trg

echo "# Check if the trigger actually works by doing a set of ^b and write of ^a"
$gtm_exe/mumps -run %XCMD 'set ^b=100 zwrite ^a'

$gtm_tst/com/dbcheck.csh # Trigger defn not loaded on secondary. No -extract
