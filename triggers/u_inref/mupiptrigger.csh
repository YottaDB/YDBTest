#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2010, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
source $gtm_tst/com/dbcreate.csh mumps 5

# [GTM-7974] MUPIP TRIGGER -SELECT=^GBLNAME* does not select all matching globals in some cases
# map ^bard to DREG and expect it to be selected by -select=^b*
$GDE << GDE_EOF >&! gde_change.out
add -name ba* -reg=DREG
exit
GDE_EOF

# Testing the trigger command file loading
# * Basic load operations
# 	1. Loading of triggers with none in the DB
# 	2. Appending of the same triggers in the DB
# 	3. Removal of all the same triggers from the DB
# 	4. Appending of the same triggers with none in the DB
#
# * Testing with NULL files
# 	1. Append with a null trigger file
# 	2. Remove with a null trigger file
# 	3. Load a null trigger file against existing triggers (previous test)
# 	4. Load a null trigger file again
#
# * Testing trigger append and removal operations
# 	1a. Remove non-existent triggers
# 	* Load a file with real triggers
# 	1. Remove non-existent triggers (again)
# 	2. Add new triggers
# 	3. Remove new triggers
#
# * Testing trigger matching (asymmetric testing)
# 	1. Append various combinations of triggers that look like existing triggers
# 	2. Remove various combinations of triggers that look like existing triggers
# 	3. Command merging
# 	4. Options merging
#
# * Testing SELECT and TRIGGERFILE command matching
# 	1. see "Test Basic Loading, Appending, and Removal Options with directories and other assorted file types"
# 	2. see "Test Basic SELECT Options"
# 	3. load a ztkill over a kill and vice versa
#
# * Testing that the trigger ends up in the right DB?  TODO!!!! <--- validate with journaling test
# * Testing trigger installation resiliency TODO!!!!!!!!! <--- validate with maxnames test
# 	1. kill the trigger load to validate the transaction does not complete
# 	2. overlapp installation and execution of a trigger
#
# * Tirgger error handling in MUPIP TODO <--- gets its own test
# 	1. gtm_trigger_etrap is not set
# 	has the implicit Set $ETRAP="""" If $ZJOBEXAM()
# 	2. gtm_trigger_etrap is set
#

echo "_________________________________________________________________"
echo "===================="
# 	1. Loading of triggers with none in the DB
echo "Test Basic Loading, Appending, and Removal Options with the same trigger file"
echo "Load a trigger file triggers.trg with -trig=<filename>"
cat  > triggers.trg  <<TFILE
+^a	-command=SET	-xecute="do ^twork"
+^b	-command=SET	-xecute="do ^twork"
+^c	-command=SET	-xecute="do ^twork"
+^d	-command=SET	-xecute="do ^twork"
+^a(0,:,:) -xecute="do tsubrtn^twork" -options=i -command=sEt,KilL
+^a(:) -command=zTkIll,zw,s -xecute="do ^twork"
+^a(:"b";"m":"x") -piece=1:8 -xecute="do ^tkilla" -delim="\`"  -command=s,zkILL -options=noc,noi
+^a(:2;5:) -command=s -xecute="do ^tkilla" -delim=\$zchar(126)_\$char(96) -piece=1 -options=isolation
+^a(2:,:"m";10;20;25;30;35;44;50,:) -command=S,zk,zw,kilL -xecute="do multi^tkilla" -zdelim=\$zchar(9)_\$zchar(254)_""""  -piece=1:3;7:8
;;;; fix for non unicode ^a(:,":":";";5:) -command=sET  -xecute="set mc=""""" -zdelim=\$char(8364)_\$char(65284) -piece=1:3;5:6;7:8 -options=consistencycheck
+^a(tvar=:,tvar2="t":"z",tvar3=:10;20) -delim="""" -piece=4;5;6 -command=s -xecute="do tsubrtn^twork" -options=i,c
+^a(tvar=:,tvar2="a";"g":"z",tvar3=:10;20) -delim="^" -piece=4;5;6 -command=s  -xecute="do tsubrtn^twork" -options=i,c
+^b(0,:,:) -xecute="do tsubrtn^twork" -options=i -command=sEt,KilL
+^c(:) -command=zTkIll,zw,s -xecute="do ^twork"
+^b(:"b";"m":"x") -piece=1:8 -xecute="do ^tkilla" -delim="\`"  -command=zkILL,s -options=noc,noi
+^bard(:2;5:) -command=s -xecute="do ^tkilla" -delim=\$zchar(126)_\$char(96) -piece=1 -options=isolation
+^bard(2:,:"m";10;20;25;30;35;44;50,:) -command=sET,zw,kilL -xecute="do multi^tkilla" -zdelim=\$zchar(9)_\$zchar(254)_""""  -piece=1:3;7:8
;;;; fix for non unicode ^bard(:,":":";";5:) -command=sET  -xecute="set mc=""""" -zdelim=\$char(8364)_\$char(65284) -piece=1:3;5:6;7:8 -options=consistencycheck
+^drek(tvar=:,tvar2="t":"z",tvar3=:10;20) -delim="""" -piece=4;5;6 -command=s -xecute="do tsubrtn^twork" -options=i,c
+^drek(tvar=:,tvar2="a";"g":"z",tvar3=:10;20) -delim="^" -piece=4;5;6 -command=s  -xecute="do tsubrtn^twork" -options=i,c
TFILE
sed 's/^+/-/' triggers.trg > triggersm.trg
$load triggers.trg
$show

# 	2. Appending of the same triggers in the DB
echo "Appending of the same triggers in the DB"
$load triggers.trg
$show

# 	3. Removal of all the same triggers from the DB
echo "Removal of all the same triggers from the DB"
$load triggersm.trg
$show
$drop

# 	4. Appending of the same triggers with none in the DB
echo "Appending of the same triggers with none in the DB"
$load triggers.trg
$show reload.trg

# 	5. Appending and removal of the same triggers, but use the output of the show command
echo "Appending and removal of the same triggers, but use the output of the show command"
$load reload.trg
sed 's/^+/-/' reload.trg > reloadm.trg
$load reloadm.trg
$show


echo "_________________________________________________________________"
echo "===================="
echo "Test Basic Loading, Appending, and Removal Options with null files"
touch null.trg

# 	1. Append with a null trigger file
echo "Load an empty trigger file null.trg with -triggerfile=<filename>"
$load null.trg
$show

# 	2. Remove with a null trigger file
#echo "Load an empty trigger file null.trg with -triggerfile=-<filename>"
#$load null.trg
#$show

cat > null.trg << EOF
-*
EOF
# 	3. Unload all triggers with a null trigger file twice
echo "Load an empty trigger file null.trg with -trig=<filename>, but answer no"
echo "n" | $MUPIP trigger -trig=null.trg
$show
echo "Load an empty trigger file null.trg with -trig=<filename> and answer yes"
echo "y" | $MUPIP trigger -trig=null.trg
$show

echo "Load an empty trigger file null.trg with -trig=<filename> again"
echo "y" | $MUPIP trigger -trig=null.trg
$show


echo "_________________________________________________________________"
echo "===================="
echo "Test Basic Loading, Appending, and Removal Options with non-existent files"
# 	1. Append with a non-existent trigger file
echo "Load a non-existent file with -triggerfile=<filename>"
$MUPIP trigger -triggerfile=

# 	2. Remove with a non-existent trigger file
#echo "Load a non-existent file with -triggerfile=-<filename>"
#$MUPIP trigger -triggerfile=-

# 	3. Unload all triggers with a non-existent trigger file
echo "Load a non-existent file with -trig=<filename>, but answer no"
echo "n" | $MUPIP trigger -trig=
echo "Load a non-existent file with -trig=<filename> and answer yes"
echo "y" | $MUPIP trigger -trig=


echo "_________________________________________________________________"
echo "===================="
echo "Test Basic Loading, Appending, and Removal Options with directories and other assorted file types"
# 	1. Append with a directory
echo "Load a directory with -triggerfile=<filename>"
$MUPIP trigger -triggerfile=`pwd`

# 	2. Remove with a directory <- No longer applies
#echo "Load a directory with -triggerfile=<filename>"
#$MUPIP trigger -triggerfile=`pwd`

# 	3. Unload all triggers with a directory
echo "Load a directory with -trig=<filename>, but answer no"
echo "n" | $MUPIP trigger -trig=.
echo "Load a directory with -trig=<filename> and answer yes"
echo "y" | $MUPIP trigger -trig=.

cat  > MT.trg  <<TFILE
; This file is empty

; need to test what happens when there are no triggers in a file
TFILE

cat > ztrload.m << MPROG
	write !,"Doing the something similar with ZTrigger",!
	set \$etrap="write \$char(9),""\$ZSTATUS="",\$zstatus,! set \$ecode="""""
	write "pass in an empty file ",\$ztrigger("file","MT.trg"),!
	write "pass in a nonexistent file ",\$ztrigger("file","noexist"),!
	write "pass in the CWD ",\$ztrigger("file","."),!
	write "pass in the PWD ",\$ztrigger("file","`pwd`"),!
	write "pass in a null string ",\$ztrigger("file",""),!
MPROG
$gtm_exe/mumps -run ztrload

echo "_________________________________________________________________"
echo "===================="
echo "Testing trigger append and removal operations"
# 	1. Remove non-existent triggers
echo "Remove non-existent triggers"
cat  > remove.trg  <<TFILE
+^a -command=zkill,zw		-xecute="do ^twork"
+^b	-command=k,zkill,zw	-xecute="do ^twork"
+^c	-command=k,zkill,zw	-xecute="do ^twork"
+^d	-command=k,zkill,zw	-xecute="do ^twork"
TFILE
sed 's/^+/-/' remove.trg > removem.trg
$load removem.trg
$show

echo "Load a trigger file appendremove.trg with -trig=<filename>"
cat  > appendremove.trg  <<TFILE
-*
+^a	-command=SET	-xecute="do ^twork"
+^b	-command=SET	-xecute="do ^twork"
+^c	-command=SET	-xecute="do ^twork"
+^d	-command=SET	-xecute="do ^twork"
+^a(0,:,:) -xecute="do tsubrtn^twork" -options=i -command=sEt,KilL
+^a(:) -command=zTkIll,zw,s -xecute="do ^twork"
+^a(:"b";"m":"x") -piece=1:8 -xecute="do ^tkilla" -delim="\`"  -command=s,zkILL -options=noc,noi
+^a(:2;5:) -command=s -xecute="do ^tkilla" -delim=\$zchar(126)_\$char(96) -piece=1 -options=isolation
+^a(2:,:"m";10;20;25;30;35;44;50,:) -command=S,zk,zw,kilL -xecute="do multi^tkilla" -zdelim=\$zchar(9)_\$zchar(254)_""""  -piece=1:3;7:8
;;;; fix for non unicode ^a(:,":":";";5:) -command=sET  -xecute="set mc=""""" -zdelim=\$char(8364)_\$char(65284) -piece=1:3;5:6;7:8 -options=consistencycheck
+^a(tvar=:,tvar2="t":"z",tvar3=:10;20) -delim="""" -piece=4;5;6 -command=s -xecute="do tsubrtn^twork" -options=i,c
+^a(tvar=:,tvar2="a";"g":"z",tvar3=:10;20) -delim="^" -piece=4;5;6 -command=s  -xecute="do tsubrtn^twork" -options=i,c
+^b(0,:,:) -xecute="do tsubrtn^twork" -options=i -command=sEt,KilL
+^c(:) -command=zTkIll,zw,s -xecute="do ^twork"
+^b(:"b";"m":"x") -piece=1:8 -xecute="do ^tkilla" -delim="\`"  -command=zkILL,s -options=noc,noi
+^bard(:2;5:) -command=s -xecute="do ^tkilla" -delim=\$zchar(126)_\$char(96) -piece=1 -options=isolation
+^bard(2:,:"m";10;20;25;30;35;44;50,:) -command=sET,zw,kilL -xecute="do multi^tkilla" -zdelim=\$zchar(9)_\$zchar(254)_""""  -piece=1:3;7:8
;;;; fix for non unicode ^bard(:,":":";";5:) -command=sET  -xecute="set mc=""""" -zdelim=\$char(8364)_\$char(65284) -piece=1:3;5:6;7:8 -options=consistencycheck
+^drek(tvar=:,tvar2="t":"z",tvar3=:10;20) -delim="""" -piece=4;5;6 -command=s -xecute="do tsubrtn^twork" -options=i,c
+^drek(tvar=:,tvar2="a";"g":"z",tvar3=:10;20) -delim="^" -piece=4;5;6 -command=s  -xecute="do tsubrtn^twork" -options=i,c
+^apiece -command=s -piece=1;2;3;4;5 -delim=""" " -xecute="do ^nothing"
+^bpiece -command=s,ztk,zk -piece=1:5 -delim="|" -xecute="do ^nothing" -options=noisolation,noconsistency
TFILE
$load appendremove.trg "" -noprompt
$show

# 	1a. Remove non-existent triggers (again)
echo "Remove non-existent triggers (again)"
$load removem.trg
$show

# 	2. Add new triggers
echo "Add new triggers"
$load remove.trg
$show

# 	3. Remove new triggers
echo "Remove new triggers"
$load removem.trg
$show


echo "_________________________________________________________________"
echo "===================="
echo "Testing trigger matching for append and removal operations with lookalike triggers"
echo "Load a trigger file lookalikes.trg with -triggerfile=<filename>"
cat  > lookalikes.trg  <<TFILE
+^a -command=s,zk,zw		-xecute="do ^twork"
+^b	-command=sET	-xecute="do ^twerk"
+^b	-command=seT	-xecute="do ^twerk" -piece=1 -delim=":"
+^c	-command=zkiLL,zw	-xecute="do ^twerk"
+^apiece -command=set -piece=1:4;5 -delim=""" " -xecute="do ^nothing"
+^apiece -command=set -piece=1:6 -delim=""" " -xecute="do ^nothing"
+^d	-command=k,kill,zkill,zw	-xecute="do ^twork"
+^bpiece -command=zk,s -piece=1:2;3:5 -delim="|" -xecute="do ^nothing" -options=noi,noc
+^bpiece -command=zk,s -piece=1;2;3:5 -zdelim="|" -xecute="do ^nothing" -options=noc,noi
+^a(:2;5:) -command=s -xecute="do ^tkilla" -delim="\$char(126)_\$char(96)" -piece=1 -options=i
+^a(tvar=:2;5:) -command=s -xecute="do ^tkilla" -delim="\$zchar(126)_\$char(96)" -piece=1 -options=i
+^a(tvar=:2;5:) -command=s -xecute="do ^tkilla" -delim="\$zchar(126)_\$char(96)" -piece=1 -options=i
TFILE
$load lookalikes.trg
$show

# removing triggers with different targetting
# simple same match remove:	^a	-command=SET	-xecute="do ^twork"
# remove one command:		^a(2:,:"m";10;20;25;30;35;44;50,:) -command=zk -xecute="do multi^tkilla" -zdelim="\$zchar(9)_\$char(254)_"""  -piece=1:3;7:8
# remove 1 cmd with pieces collapsed: ^a(tvar=:,tvar2="t":"z",tvar3=:10;20) -delim="""" -piece=4:6 -command=s -xecute="do tsubrtn^twork" -options=i,c
$drop
echo "_________________________________________________________________"
echo "===================="
echo "Testing trigger matching symmetry for append and removal operations"
echo "Load a trigger file symmetry_up.trg with -triggerfile=<filename>"
cat  > symmetry_up.trg  <<TFILE
; command symmetry
+^a -command=s,zk,zw		-xecute="do ^twork"

; delim to command symmetry
+^dsym -command=S,K,ZW -xecute="set ^a=55" -delim="|"
+^dsym -command=S,K    -xecute="set ^a=55" -delim=";"

; piece to command symmetry
+^dsym -command=S,ZK   -xecute="set ^a=55" -delim="." -piece=1
+^pdsym -command=S,ZW,K -xecute="set ^a=99" -delim="." -piece=1:10

; subscript symmetry
+^subs("a") -command=S,K,ZW -xecute="set b=9"
+^subs("c") -command=S,k,ZW -xecute="set b=9"
+^subs("b") -command=S,k,ZW -xecute="set b=9"
+^subs(2,"A";"B";"C") -command=S,K,ZK -xecute="set b=9"
TFILE
$load symmetry_up.trg
$show up.trg
$grep -Ev "^;trigger name" up.trg | sort > up1.trg

echo "Special case for ZTKIll symmetry"
cat  > symmetry_ztkill.trg  <<TFILE
; delim to command symmetry
+^dsym -command=S,ZTK -xecute="set ^a=55" -delim=":"
TFILE
$load symmetry_ztkill.trg FAIL

echo "Load a trigger file symmetry_down.trg with -triggerfile=<filename>"
cat  > symmetry_down.trg  <<TFILE
; command symmetry
; should see SET and ZKILL matched, but not ZTKill
+^a -command=s,zw,ztk		-xecute="do ^twork"

; delim to command symmetry
; should see KILL matched, but not SET
+^dsym -command=S,K -xecute="set ^a=55" -delim="."

; piece to command symmetry (check whether the value of piece affects the KILL removal)
; should see KILL matched but not SET
+^dsym -command=S,K -xecute="set ^a=55" -delim="." -piece=12

; piece to command symmetry (ensure that piece range compression occurs)
; The following two match on kill side, but append a ZK and K to the same node
; note that the pieces collapes to the same values
+^pdsym -command=S,K -xecute="set ^a=99" -delim="." -piece=1:5;6:10
+^pdsym -command=S,ZK -xecute="set ^a=99" -delim="." -piece=1:9;10

; subscript symmetry
; should see the following subscripts remove
+^subs("c") -command=S,k,ZW -xecute="set b=9"
; this is not removed due to the whole subscript being treated as a target and not the parts
+^subs(2,"C") -command=S,k,ZW -xecute="set b=9"
TFILE
sed 's/^+/-/' symmetry_down.trg > symmetry_downm.trg
$load symmetry_downm.trg
$show r_down.trg
$grep -Ev "^;trigger name" r_down.trg | sort > r_down1.trg

$load symmetry_down.trg
$show a_down.trg
$grep -Ev "^;trigger name" a_down.trg | sort > a_down1.trg

echo diff up.trg a_down.trg
diff up1.trg a_down1.trg |& $grep -E '<|>'
echo diff up.trg r_down.trg
diff up1.trg r_down1.trg |& $grep -E '<|>'

echo "_________________________________________________________________"
echo "===================="
# 	1. Testing the mupip trigger -select command
echo "Test Basic SELECT Options"
$drop
$load triggers.trg
$show
echo "$MUPIP trigger -select select_all.trg"
$MUPIP trigger -select select_all.trg || echo "FAIL"
echo "$MUPIP trigger -select select_all2.trg"
$MUPIP trigger -select select_all2.trg || echo "FAIL"
echo diff select_all.trg select_all2.trg
diff select_all.trg select_all2.trg
echo "$MUPIP trigger -select="
$MUPIP trigger -select=
echo ""
echo "$MUPIP trigger -select=^a"
$MUPIP trigger -select=^a mptrg1.trg
if (-e mptrg1.trg) cat mptrg1.trg
echo $MUPIP trigger -select="^a,^a"
$MUPIP trigger -select=\"^a,^a\" mptrg1aa.trg
if (-e mptrg1aa.trg) cat mptrg1aa.trg
echo $MUPIP trigger -select=\"^a,^b\"
$MUPIP trigger -select="^a,^b" mptrg2.trg
if (-e mptrg2.trg) cat mptrg2.trg
echo $MUPIP trigger -select=\"^a,^b\*\"
$MUPIP trigger -select="^a,^b*" mptrg3.trg
if (-s mptrg3.trg) then
	cat mptrg3.trg
else
	echo "Bad GVN"
endif
echo $MUPIP trigger -select=\"^drek,^c\(:\),^bard\"
$MUPIP trigger -select="^drek,^c(:),^bard" mptrg4.trg
echo "status of the above -select command : $status"
if (-e mptrg4.trg) cat mptrg4.trg
echo "Existing files are not overwritten"
echo $MUPIP trigger -select=^a `pwd`
$MUPIP trigger -select=^a `pwd`

cat > ztselect.m << MPROG
	write !,"Doing the something similar with ZTrigger",!
	set \$etrap="write \$char(10,9),""\$ZSTATUS="",\$zstatus,! set \$ecode="""""
	write "select with no opt params ",\$ztrigger("select"),!
	write "==========",!
	write "select with null opt params ",\$ztrigger("select",""),!
	write "==========",!
	write "select with asterix opt params ",\$ztrigger("select","*"),!
	write "==========",!
	write "select with '^a' ",\$ztrigger("select","^a"),!
	write "==========",!
	write "select with 'a#*' ",\$ztrigger("select","a#*"),!
	write "==========",!
	write "select with 'a#*#' ",\$ztrigger("select","a#*#"),!
	write "==========",!
	write "select with '^a,^b' ",\$ztrigger("select","^a,^b"),!
	write "==========",!
	write "select with '^a,^b*' ",\$ztrigger("select","^a,^b*"),!
	write "==========",!
	write "select with '^drek,^c(:),^bard' ",\$ztrigger("select","^drek,^c(:),^bard"),!
	write !
MPROG
$gtm_exe/mumps -run ztselect

# In this test, we expect trigger select to be different between primary and secondary due to the region name being different
# and we want that captured sorted_compare.csh (invoked from RF_EXTR.csh) as reference file relies on it. Set env var accordingly.
setenv gtm_test_trigdiff_exact 1
$gtm_tst/com/dbcheck.csh -extract
