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
#ZTRIGINVACT
#
#ZTRIGINVACT, Missing or invalid subcode (first) parameter given to $ZTRIGGER()
#
#Run Time Error: The first argument to $ZTRIGGER() is required to specify its mode of action.
#
#Action: for the first argument of $ZTRIGGER() use an expression that evaluates to 'FILE', 'ITEM' or 'SELECT'.

setenv gtm_trigger_etrap 'write $c(9),"$zlevel=",$zlevel," : $ztlevel=",$ztlevel," : $ZSTATUS=",$zstatus,! set $ecode=""'
$gtm_tst/com/dbcreate.csh mumps 1

cat > ztrigger.trg << TFILE
+^notp -commands=S -xecute="set ztvalue=\$ztrigger(""file"",\$ztvalue)"
TFILE

cat > ztriginvact.m << MPROG
ztriginvact
	if '\$data(^ztriginvact) set ^ztriginvact=0
	set \$etrap="write \$char(9),""\$ZSTATUS="",\$zstatus,! set \$ecode="""""
	set status=\$piece(\$zcmdline," ",1)
	set arg=\$piece(\$zcmdline," ",2)
	set arg2=\$piece(\$zcmdline," ",3,\$length(\$zcmdline," "))
	;
	set count=\$select(arg2'="":2,1:1)
	; don't use else because onearg changes \$test, causing
	; twoarg to fire
	if count=1 do onearg(status,arg)
	if count=2 do twoarg(status,arg,arg2)
	quit
	;
	; invoke ztrigger with one argument
onearg(status,arg)
	if ('status)&(^ztriginvact) write !,"We are looking to see the ZTRIGINVACT using ztrigger with one arg ",arg,!
	set zstatus=\$ztrigger(arg)
	if status'=zstatus  use \$p write "FAILED: ztrigger(",arg,")",!
	else  use \$p write "PASS: ztrigger(",arg,")",!
	quit
	;
	; invoke ztrigger with two arguments
twoarg(status,arg,arg2)
	if ^ztriginvact write !,"We are looking to see the ZTRIGINVACT using ztrigger with two args ",arg,",",arg2,!
	set zstatus=\$ztrigger(arg,arg2)
	if status'=zstatus  use \$p write "FAILED: ztrigger(",arg,",",arg2,")",!
	else  use \$p write "PASS: ztrigger(",arg,",",arg2,")",!
	quit
setinvact
	set ^ztriginvact=1
	quit
MPROG

# Short forms
echo ""
echo "Trying the passing commands first"
echo "Use the short form names of each command"
echo "Select"
$gtm_exe/mumps -run ztriginvact 1 S

echo ""
echo "Item"
$gtm_exe/mumps -run ztriginvact 1 I '+^notp -commands=S -xecute="set ztvalue=$ztrigger(""file"",$ztvalue)"'

echo ""
echo "File"
$gtm_exe/mumps -run ztriginvact 1 F ztrigger.trg

# Mixed case
echo ""
echo "Mix the case of the commands"
echo "Select"
$gtm_exe/mumps -run ztriginvact 1 SelecT

echo ""
echo "File"
$gtm_exe/mumps -run ztriginvact 1 filE ztrigger.trg

echo ""
echo "Item"
$gtm_exe/mumps -run ztriginvact 1 iTEM '+^notp -commands=S -xecute="set ztvalue=$ztrigger(""file"",$ztvalue)"'

# Bad files do not generate ZTRIGINVACT
echo ""
echo "Start with passing in bad files to ztrigger"
echo "Nonexistent file"
$gtm_exe/mumps -run ztriginvact 0 F noexist

echo ""
echo "No permissions file"
touch noperms ; chmod 000 noperms
$gtm_exe/mumps -run ztriginvact 0 F noperms
# need to be able to delete it after the test
chmod 664 noperms ; rm noperms

echo ""
echo "Bad select values"
$gtm_exe/mumps -run ztriginvact 0 select '+^notp -commands=S -xecute="set ztvalue=$ztrigger(""file"",$ztvalue)"'
$gtm_exe/mumps -run ztriginvact 0 select '-*'
$gtm_exe/mumps -run ztriginvact 0 select '- *'
$gtm_exe/mumps -run ztriginvact 0 select '^^'
$gtm_exe/mumps -run ztriginvact 1 S

##########################################
# We are now testing for invalid actions #
##########################################
$gtm_exe/mumps -run setinvact^ztriginvact
echo ""
echo "Using anything other than ITEM/I, FILE/F, SELECT/S as the"
echo "first argument is an invalid action"
$gtm_exe/mumps -run ztriginvact 0 BADARG
$gtm_exe/mumps -run ztriginvact 0 BADARG BADARG

echo ""
echo "Passing NULL parameters into ztrigger"
cat > nullz.m << MPROG
nullz
	set \$etrap="write \$char(9),""\$ZSTATUS="",\$zstatus,! halt"
	set x=\$ztrigger(\$char(0,0,0,0),\$char(0))
file
	set \$etrap="write \$char(9),""\$ZSTATUS="",\$zstatus,! halt"
	set x=\$ztrigger("file",\$char(0))
item
	set \$etrap="write \$char(9),""\$ZSTATUS="",\$zstatus,! halt"
	set x=\$ztrigger("item",\$char(0))
select
	set \$etrap="write \$char(9),""\$ZSTATUS="",\$zstatus,! halt"
	set x=\$ztrigger("select",\$char(0))
MPROG
$gtm_exe/mumps -run nullz
$gtm_exe/mumps -run file^nullz
$gtm_exe/mumps -run item^nullz
$gtm_exe/mumps -run select^nullz

echo ""
echo "The use of FILE or ITEM without arguments is a valid action"
echo "I"
$gtm_exe/mumps -run ztriginvact 1 I
echo "F"
$gtm_exe/mumps -run ztriginvact 1 F
echo "file"
$gtm_exe/mumps -run ztriginvact 1 file
echo "ITEM"
$gtm_exe/mumps -run ztriginvact 1 ITEM
echo ""

$echoline
echo "Need to fuzz the command arguments"
echo "Trying :+"
$gtm_exe/mumps -run ztriginvact 0 +
echo "Trying :-"
$gtm_exe/mumps -run ztriginvact 0 -
echo "Trying :-*"
$gtm_exe/mumps -run ztriginvact 0 -\*
echo "Trying :*"
$gtm_exe/mumps -run ztriginvact 0 \*
echo "Trying :-select"
$gtm_exe/mumps -run ztriginvact 0 -select
echo '"'
$gtm_exe/mumps -run ztriginvact 0 \"
echo '""'
$gtm_exe/mumps -run ztriginvact 0 \"\"
echo "Trying :'"
$gtm_exe/mumps -run ztriginvact 0 \'
echo "Trying :''"
$gtm_exe/mumps -run ztriginvact 0 \'\'


$echoline
$gtm_tst/com/dbcheck.csh -extract

