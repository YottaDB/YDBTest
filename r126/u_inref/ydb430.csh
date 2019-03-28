#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# Test that $ZTRIGGER and MUPIP TRIGGER work with numeric subscripts having a decimal point.'
echo '# Also test that triggers for ^x(2) or ^x(2.0) or ^x("2") are treated as identical.'
echo ""

set backslash_quote	# needed for backslash usages below

echo "	do ^sstep" >>& drivetrig.m
@ cnt = 10
foreach subs (2 2. 2.0 2.00 02 002 2.2 2.200 2.2001 .02 .020)
	echo "+^x($subs)      -commands=SET -xecute=\"write \"\"trigger\"\",!\"" >& input1_$cnt.trg
	echo "	set ^x($subs)=1_$cnt" >>& drivetrig.m
	echo "+^x(-$subs)      -commands=SET -xecute=\"write \"\"trigger\"\",!\"" >& input2_$cnt.trg
	echo "	set ^x(-$subs)=2_$cnt" >>& drivetrig.m
	echo "+^x(\"$subs\")  -commands=SET -xecute=\"write \"\"trigger\"\",!\"" >& input3_$cnt.trg
	echo "	set ^x(\"$subs\")=3_$cnt" >>& drivetrig.m
	echo "+^x(\"-$subs\") -commands=SET -xecute=\"write \"\"trigger\"\",!\"" >& input4_$cnt.trg
	echo "	set ^x(\"-$subs\")=4_$cnt" >>& drivetrig.m
	@ cnt = $cnt + 1
end

echo ""
echo "#########################################################################3"
echo "# Test 1 : Use ZTRIGGER(FILE)"
echo "#########################################################################3"
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log1.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log1.txt
endif
foreach file (input*.trg)
	echo "# Testing $file with : WRITE \$ZTRIGGER(\"FILE\"),!"
	echo "# File contents : `cat $file`"
	$ydb_dist/mumps -run ^%XCMD "WRITE \$ZTRIGGER(\"FILE\",\"$file\"),!"
	@ status1 = $status
	if ($status1) then
		echo "  --> Above command failed with exit status : $status1"
	endif
end
echo "# Display triggers at end of Test 1"
cat /dev/null | $MUPIP trigger -select >& trig1.txt
cat trig1.txt
echo "# Check that exactly ONE trigger (neither higher or lower) is invoked for SET of every possible node"
$ydb_dist/mumps -run drivetrig
echo "# Check and shutdown the DB"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log1.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log1.txt
endif

echo ""
echo "#########################################################################3"
echo "# Test 2 : Use ZTRIGGER(ITEM)"
echo "#########################################################################3"
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log2.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log2.txt
endif
foreach file (input*.trg)
	echo "# Testing $file with \$ZTRIGGER(\"ITEM\")"
	$ydb_dist/mumps -run ydb430 $file
	@ status1 = $status
	if ($status1) then
		echo "  --> Above command failed with exit status : $status1"
	endif
end
echo "# Verify Test 2 created same triggers as Test 1"
cat /dev/null | $MUPIP trigger -select >& trig2.txt
echo "# diff trig1.txt trig2.txt. Expect no output"
diff trig1.txt trig2.txt >& /dev/null
if ($status) then
	echo "# diff trig1.txt trig2.txt returned non-zero status. Expected 0 status. diff output follows"
	diff trig1.txt trig2.txt
endif
echo "# Check and shutdown the DB"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log2.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log2.txt
endif

echo ""
echo "#########################################################################3"
echo "# Test 3 : Use MUPIP TRIGGER -TRIGGER="
echo "#########################################################################3"
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log3.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log3.txt
endif
foreach file (input*.trg)
	echo "# Testing $file with MUPIP TRIGGER"
	$ydb_dist/mupip trigger -noprompt -trigger=$file
	@ status1 = $status
	if ($status1) then
		echo "  --> Above command failed with exit status : $status1"
	endif
end
echo "# Verify Test 3 created same triggers as Test 1"
cat /dev/null | $MUPIP trigger -select >& trig3.txt
echo "# diff trig1.txt trig3.txt. Expect no output"
diff trig1.txt trig3.txt >& /dev/null
if ($status) then
	echo "# diff trig1.txt trig3.txt returned non-zero status. Expected 0 status. diff output follows"
	diff trig1.txt trig3.txt
endif
echo "# Check and shutdown the DB"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log3.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log3.txt
endif
