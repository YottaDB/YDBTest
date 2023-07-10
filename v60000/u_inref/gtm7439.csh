#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Since the reference file for this test has "SUSPEND_OUTPUT 4G_ABOVE_DB_BLKS" usage, it needs to fixate
# the value of the "ydb_test_4g_db_blks" env var in case it is randomly set by the test framework to a non-zero value.
if (0 != $ydb_test_4g_db_blks) then
	echo "# Setting ydb_test_4g_db_blks env var to a fixed value as reference file has 4G_ABOVE_DB_BLKS usages" >> settings.csh
	setenv ydb_test_4g_db_blks 8388608
endif

setenv autoswitchlimit 16384					# TODO : Should probably fetch this value from the source code
setenv tst_jnl_str "-journal=enable,on,nobefore,auto=16384"	# Minimum autoswitch limit that we know of as of V6.0-000
setenv gtm_test_jnl "SETJNL"					# To force journal creation in dbcreate time.
$gtm_tst/com/dbcreate.csh mumps 1

echo
$echoline
echo "# Extend the database to a considerable size so that unnecessary file extensions won't happen. This helps in calculating"
echo "# how many updates need to be done."
$echoline
$MUPIP extend DEFAULT -blocks=12000

echo
$echoline
echo "# Find out the size of one update"
$gtm_exe/mumps -run %XCMD 'set ^b($incr(i))=$j(i,200)'
$MUPIP journal -extract -noverify -detail -forward -fences=none mumps.mjl >&! jnl_extract.out
if ($status) then
	echo "TEST-E-FAIL - Journal Extract failed. Check jnl_extract.out for more details"
	exit -1
endif
set hexsz = `$grep -w SET mumps.mjf | $tst_awk '{print $2}' | sed 's/\[//g' | sed 's/\]//g'`
setenv updatesz `$gtm_tst/com/radixconvert.csh h2d $hexsz | $tst_awk '{print $5}'`
echo "Autoswitchlimit = GTM_TEST_DEBUGINFO: $autoswitchlimit"
echo "Size of one update = GTM_TEST_DEBUGINFO: $updatesz"
$echoline

echo
$echoline
echo "# Now, fire up the updates and continue until the Journal File is almost full"
$echoline
$gtm_exe/mumps -run testbed^gtm7439

echo
$echoline
echo "# Now, do MUPIP EXTENDs each of which writes PINI, INCTN and PFIN records. Journal File should have no trouble extending."
$echoline
set cntr=1
set prev_num_journals = `ls -l *.mjl* | wc -l`
echo "Prev # of Journals = $prev_num_journals" >>&! num_journals.out

# At this point, we should have exactly one journal file. If we have more than one, then that indicates journal files were switched
# in testbed^gtm7439.
if ($prev_num_journals > 1) then
	echo "TEST-E-FAIL, more than 1 journal file found after testbed creation. Test cannot continue"
	exit -1
endif

while ($cntr < 50)
	$MUPIP extend DEFAULT -blocks=100 >&! mupip_extend_$cntr.out
	if ($status) then
		echo "TEST-E-FAIL, MUPIP EXTEND failed. Check mupip_extend_$cntr.out for more details"
		exit -1
	endif
	@ cntr = $cntr + 1
	set num_journals = `ls -l *.mjl* | wc -l`
	echo "Curr # of Journal = $num_journals" >>&! num_journals.out
	if ($num_journals > $prev_num_journals) then
		break
	endif
end

if ($cntr == 50) then
	echo "TEST-E-FAIL, Journal file not switched even after $cntr MUPIP EXTENDs"
	exit -1
endif

$gtm_tst/com/dbcheck.csh
