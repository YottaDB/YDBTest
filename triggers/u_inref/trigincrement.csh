#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2010, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# trigincrement - test \$increment in multiple jobs executing triggers

$gtm_tst/com/dbcreate.csh mumps 1

# ------------------------------------------------------
# --- Create trig.txt file (input for mupip trigger)
cat << TRIG  > trigincrement.trg
+^CIF(acn=:) -commands=SET -xecute="Do ^triginc1"
+^CIF(999) -commands=SET -xecute="set ^stop=1"
TRIG

# ------------------------------------------------------
# --- Create triginc1.m trigger program that modifies CIF1()
cat << TFILE  > triginc1.m
	set x=\$INCR(^CIF1(acn))
	quit
TFILE

# ------------------------------------------------------
# --- Create trigincrement.m application program
# --- start 5 jobs in background which execute the child entry
# --- each child will update ^CIF() entries via \$INCREMENT until ^stop is true
# --- the parent will wait for 10+ seconds before setting ^stop true
# --- each child will attempt to write the non-existent y local which will
# --- fire the etr trap.  Each one will do a zwrite of its current value for x
cat << TRIGINCR  > trigincrement.m
	set ^stop=0
	set jmaxwait=0
	do ^job("child^trigincrement",5,"""""")
	for i=1:1:300  quit:^stop=1  hang 1
	if ^stop'=1 write "TEST-W-WARN : TIMEOUT nothing set ^stop",!
	set ^stop=1
	do wait^job
	quit
child	;
	set \$etrap="do etr"
	for i=1:1  set x=\$INCR(^CIF(i#1000)) quit:^stop=1
	; filler for the reference file
	write y
	quit
etr	;
	zwrite x
	write "\$zstatus=",\$zstatus,!
	halt
TRIGINCR

# ------------------------------------------------------
# --- Create trigvalid.m validation program
# --- the local variable x will appear in each child_trigincrement_mjo(1-5) file as the 4th line
# --- this value or a larger one will appear in ^CIF() in the range 0-999.  This routine will find the first instance
# --- of a value which is >= x in ^CIF() and validate that ^CIF1() contains the same value via the trigger modification.
# --- start the search from ^CIF(999) backwards as the smaller values tend to be grouped at the end.  We have to
# --- look for a value in ^CIF() which is greater than or equal because on faster processors the other jobs might overwrite
# --- the value of x prior to this comparison.
cat << TRIGVALID  > trigvalid.m
validate
	for i=1:1:5  do
	. set file="child_trigincrement.mjo"_i
	. open file:(readonly:exception="g bad")
	. use file
	. for k=1:1:4 read x(i)
	. close file
	. xecute "set "_x(i)
	. set pass=0
	. for j=999:-1:0 quit:pass  do
	.. if (((x'>^CIF(j))&(^CIF1(j)=^CIF(j)))) write "Comparison ",file," passed",! set pass=1
	quit
bad
	write "Bad io for ",file,!
	halt
TRIGVALID

if ($?test_replic == 1) then
	if ($tst_org_host == $tst_remote_host) then
		cp triginc1.m $SEC_SIDE
	else
		$rcp triginc1.m "$tst_remote_host":$SEC_SIDE/
	endif
endif

$load trigincrement.trg "" -noprompt

# ------------------------------------------------------
# --- Run application program
echo "--------------------------------------------------------------------------------"
echo '  Test $increment in multiple jobs executing triggers'
echo "--------------------------------------------------------------------------------"

$gtm_exe/mumps -run trigincrement

# ------------------------------------------------------
# --- Run validation program and except all five to pass
echo "--------------------------------------------------------------------------------"
echo '  Validate all 5 jobs passed'
echo "--------------------------------------------------------------------------------"
$gtm_exe/mumps -run trigvalid

$gtm_tst/com/dbcheck.csh -extract

