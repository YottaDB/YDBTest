#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Note that this test is similar to and partially derived from
# v71000/inplaceconv_V6toV7-gtmf13547.
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F225097 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-F225097)

MUPIP REORG -UPGRADE, which completes the second phase of a V6 to V7 database transition, can run concurrently with other processing excepting other MUPIP REORG [-UPGRADE] processes. REORG -UPGRADE can work either by region or by file allowing administrator to run concurrent upgrade operations on different regions/files.

Note: FIS does not recommend running MUPIP REORG -UPGRADE with concurrent activity for MM database files on AIX due to a rare concurrency conflict.

MUPIP DOWNGRADE -VERSION=V63000A allows the current GT.M to downgrade a V6 database to the pre-V63000A EOF block format. Previously the downgrade function reported an unsupported error for a V7 versions. (GTM-F225097)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
# Disable SEMINCR to prevent shared memory segments from being left over due
# to the test system simulating many processes simultaneously accessing a single
# database file. See the following thread for details:
# https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2281
unsetenv gtm_db_counter_sem_incr
setenv gtm_test_use_V6_DBs 0  # Disable V6 mode DBs as this test already switches versions for its various test cases
source $gtm_tst/com/ydb_prior_ver_check.csh $gtm_test_v6_dbcreate_rand_ver
echo '# The below tests force the use of V6 mode to create DBs. This requires turning off ydb_test_4g_db_blks since'
echo '# V6 and V7 DBs are incompatible in that V6 cannot allocate unused space beyond the design-maximum total V6 block limit'
echo '# in anticipation of a V7 upgrade.'
setenv ydb_test_4g_db_blks 0
echo

echo "### Test 1: Run MUPIP REORG -UPGRADE while concurrently running upgrade operations on other files/regions"
echo "# Set version to: V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
setenv gtmgbldir T1.gld
echo "# Create V6 database files"
$gtm_tst/com/dbcreate.csh T1 4 -rec=262144 >& dbcreateT1.log
$gtm_dist/mumps -run GDE exit >&! gdeT1.out
echo "# Set a large value in each region of the database to slow down later MUPIP REORG -UPGRADE calls"
foreach reg ("DEFAULT" "A" "B" "C")
	echo "# Fill region $reg for 5 seconds"
	# Before spawning background process, kill ^stopfill to start with known state
	$gtm_dist/mumps -r %XCMD 'kill ^stopfill'
	# Start background process (an M program).
	($gtm_dist/mumps -run fillglobal^gtmf225097 $reg & ; echo $! >& mumpsT1$reg.pid) >&! fillT1$reg.out
	# Wait for backgrounded M program to have set ^stopfill to 0. Only then do we know it has started doing updates.
	$gtm_dist/mumps -r %XCMD 'for i=1:1 quit:$data(^stopfill)  hang 0.01'
	# Sleep for 5 seconds while backgrounded M program is performing updates
	sleep 5
	# Now signal backgrounded M program to terminate
	$gtm_dist/mumps -r %XCMD 'set ^stopfill=1'
	# Wait for backgrounded M program to terminate
	$gtm_tst/com/wait_for_proc_to_die.csh `cat mumpsT1$reg.pid` 300
end

fuser *.dat >& fuserT1.out
echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Upgrade the global directory $gtmgbldir : GDE exit"
$gtm_dist/mumps -run GDE exit >>&! gdeT1.out
echo

echo "# Perform phase 1 of in-place upgrade on region DEFAULT: MUPIP UPGRADE"
echo "y" | $gtm_dist/mupip upgrade -file T1.dat >&! mupipupgradeT1DEFAULT.out
echo "# Perform phase 1 of in-place upgrade on region AREG: MUPIP UPGRADE"
echo "y" | $gtm_dist/mupip upgrade -region AREG >&! mupipupgradeT1AREG.out
echo "# Perform phase 1 of in-place upgrade on region BREG: MUPIP UPGRADE"
echo "y" | $gtm_dist/mupip upgrade -region BREG >&! mupipupgradeT1BREG.out
echo "# Perform phase 1 of in-place upgrade on region CREG: MUPIP UPGRADE"
echo "y" | $gtm_dist/mupip upgrade -region CREG >&! mupipupgradeT1CREG.out
echo

echo "# Perform phase 2 upgrade of each region in the background to ensure each MUPIP REORG -UPGRADE process runs concurrently:"
echo "# Perform phase 2 of in-place upgrade on region DEFAULT:"
(echo "y" | $gtm_dist/mupip reorg -upgrade -region=DEFAULT -dbg & ; echo $! >&! mupipreorgT1DEFAULT.pid ) >&! mupipreorgT1DEFAULT.out
echo "# Perform phase 2 of in-place upgrade on region AREG:"
(echo "y" | $gtm_dist/mupip reorg -upgrade -region=AREG -dbg & ; echo $! >&! mupipreorgT1AREG.pid ) >&! mupipreorgT1AREG.out
echo "# Perform phase 2 of in-place upgrade on region BREG:"
(echo "y" | $gtm_dist/mupip reorg -upgrade -region=BREG -dbg & ; echo $! >&! mupipreorgT1BREG.pid ) >&! mupipreorgT1BREG.out
echo "# Perform phase 2 of in-place upgrade on region CREG:"
(echo "y" | $gtm_dist/mupip reorg -upgrade -region=CREG -dbg & ; echo $! >&! mupipreorgT1CREG.pid ) >&! mupipreorgT1CREG.out
echo

$gtm_tst/com/wait_for_proc_to_die.csh `cat mupipreorgT1DEFAULT.pid` 300
$gtm_tst/com/wait_for_proc_to_die.csh `cat mupipreorgT1AREG.pid` 300
$gtm_tst/com/wait_for_proc_to_die.csh `cat mupipreorgT1BREG.pid` 300
$gtm_tst/com/wait_for_proc_to_die.csh `cat mupipreorgT1CREG.pid` 300

echo "### Test 2: Run MUPIP REORG -UPGRADE concurrently on the same region"
echo "# Set version to: V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
setenv gtmgbldir T2.gld
echo "# Create V6 database"
$gtm_tst/com/dbcreate.csh T2 -rec=262144 >& dbcreateT2.log
$gtm_dist/mumps -run GDE exit >&! gdeT2.out
echo "# Set a large value in a region of the database to slow down later MUPIP REORG -UPGRADE calls"
echo "# Fill region DEFAULT for 5 seconds"
($gtm_dist/mumps -run fillglobal^gtmf225097 DEFAULT & ; echo $! >& mumpsT2DEFAULT.pid) >&! fillT2DEFAULT.out
sleep 5
$gtm_dist/mumps -r %XCMD "set ^stopfill=1"
$gtm_tst/com/wait_for_proc_to_die.csh `cat mumpsT2DEFAULT.pid` 300

fuser *.dat >& fuser.out
echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Upgrade the global directory $gtmgbldir : GDE exit"
$gtm_dist/mumps -run GDE exit >>&! gdeT2.out
echo

echo "# Perform phase 1 of in-place upgrade on region DEFAULT: MUPIP UPGRADE"
echo "y" | $gtm_dist/mupip upgrade -region DEFAULT >&! mupipupgradeT2DEFAULT.out
echo

echo "# Perform phase 2 of DEFAULT in the background using 2 concurrent MUPIP REORG -UPGRADE processes:"
echo "# Perform phase 2 of in-place upgrade on region DEFAULT with first process:"
(echo "y" | $gtm_dist/mupip reorg -upgrade -region=DEFAULT -dbg & ; echo $! >&! mupipreorgT2DEFAULT1.pid ) >&! mupipreorgT2DEFAULT1.out
echo "# Perform phase 2 of in-place upgrade on region DEFAULT with second process:"
(echo "y" | $gtm_dist/mupip reorg -upgrade -region=DEFAULT -dbg & ; echo $! >&! mupipreorgT2DEFAULT2.pid ) >&! mupipreorgT2DEFAULT2.out
echo

$gtm_tst/com/wait_for_proc_to_die.csh `cat mupipreorgT2DEFAULT1.pid` 300
$gtm_tst/com/wait_for_proc_to_die.csh `cat mupipreorgT2DEFAULT2.pid` 300
echo "# Confirm that one concurrent MUPIP REORG successfully upgraded the database"
echo "# and that the a second concurrent MUPIP REORG was skipped.  Expect a PASS message"
echo "# confirming that exactly 1 MUPIP REORG process completed the upgrade and"
echo "# exactly 1 MUPIP REORG process skipped the upgrade."
echo "# For more details, see the discussion thread at:"
echo "# https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2281#note_2452144014"
set passmsg = "PASS: 1 MUPIP REORG process completed the upgrade, and 1 MUPIP REORG process skipped the upgrade."
grep "MUPGRDSUCC" mupipreorgT2DEFAULT*.out | sed 's/^mupipreorg.*.out:\(.*blocks to \).*\( Linux \).*$/\1VERSION\2ARCH/g' >& mupgrdsuccT2.out
if (1 > `wc -l mupgrdsuccT2.out | cut -f 1 -d " "`) then
	echo "FAIL: expected at least 1 process to complete block upgrade and issue MUPGRDSUCC message"
endif
grep "in progress, skipping" mupipreorgT2DEFAULT*.out | sed 's/mupipreorg.*.out:\(.*\)$/\1/g' >& skippedT2.out
if ($status == 1) then
	set failmsg = ""
	grep "Upgraded 0 index blocks" mupipreorgT2DEFAULT*.out >& upgradeskippedT2.out
	set upgrade_skipped = `wc -l upgradeskippedT2.out | cut -f 1 -d " "`
	if (1 != $?upgrade_skipped) then
		set failmsg = "$failmsg\nFAIL: expected 1 process to skip index block upgrade, got $upgrade_skipped"
	endif
	grep -E "Upgraded [1-9][0-9]* index blocks" mupipreorgT2DEFAULT*.out >& upgradedT2.out
	set upgraded = `wc -l upgradedT2.out | cut -f 1 -d " "`
	if (1 != $?upgraded) then
		set failmsg = "$failmsg\nFAIL: expected 1 process to upgrade index blocks, got $upgraded"
	endif
	grep "Identified 0 associated data blocks" mupipreorgT2DEFAULT*.out >>& identificationskippedT2.out
	set identification_skipped = `wc -l identificationskippedT2.out | cut -f 1 -d " "`
	if (1 != $?identification_skipped) then
		set failmsg = "$failmsg\nFAIL: expected 1 process to skip associated data block identification, got $identification_skipped"
	else
		if ("`cat identificationskippedT2.out | cut -f 1 -d ":"`" != "`cat upgradeskippedT2.out | cut -f 1 -d ":"`") then
			set failmsg = "$failmsg\nFAIL: expected a single reorg to upgrade 0 index blocks and identify 0 associated data blocks"
		endif
	endif
	grep -E "Identified [1-9][0-9]* associated data blocks" mupipreorgT2DEFAULT*.out >>& identifiedT2.out
	set identified = `wc -l identifiedT2.out | cut -f 1 -d " "`
	if (1 != $?identified) then
		set failmsg = "$failmsg\nFAIL: expected 1 process to identify associated data blocks, got $identified"
	else
		if ("`cat identifiedT2.out | cut -f 1 -d ":"`" != "`cat upgradedT2.out | cut -f 1 -d ":"`") then
			set failmsg = "$failmsg\nFAIL: expected a single reorg to upgrade > 0 index blocks and identify > 0 associated data blocks"
		endif
	endif
	if ("`cat upgradeskippedT2.out | cut -f 1 -d ":"`" == "`cat upgradedT2.out | cut -f 1 -d ":"`") then
		set failmsg = "$failmsg\nFAIL: a single reorg both upgraded blocks and skipped blocks, expected one reorg to upgrade and a second to skip"
	endif
	if ("" == $failmsg) then
		echo $passmsg
	else
		echo $failmsg
	endif
else
	echo $passmsg
endif
echo

echo "### Test 3: Run MUPIP DOWNGRADE -VERSION=V63000A to downgrade a V6 database to V63000A block format"

echo "# Set version to: V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
setenv gtmgbldir T3.gld
echo "# Create V6 database files"
$gtm_tst/com/dbcreate.csh T3 >& dbcreateT3.log
$gtm_dist/mumps -run GDE exit >&! gdeT3.out
echo "# Set a value in the database: ^x=1"
$gtm_dist/mumps -r %XCMD "set ^x=1"

echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Perform MUPIP DOWNGRADE -VERSION=V63000A"
echo "y" | $gtm_dist/mupip downgrade -version=V63000A T3.dat >&! mupipdowngrade.out

echo "# Set version to: V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
echo "# Write the previously set value in the database: ^x=1"
$gtm_dist/mumps -r %XCMD "zwrite ^x"
echo "# Add a new value to the database then write it: ^y=2"
$gtm_dist/mumps -r %XCMD "set ^y=2"
$gtm_dist/mumps -r %XCMD "zwrite ^y"

echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Upgrade the global directory $gtmgbldir : GDE exit"
$gtm_dist/mumps -run GDE exit >>& gdeT3.out
echo "# Set a new value in the database: ^z=3"
$gtm_dist/mumps -r %XCMD "set ^z=3"
echo "# Write the previously set values in the database: ^x=1,^y=2,^z=3"
$gtm_dist/mumps -r %XCMD 'zwrite ^x,^y,^z'

$gtm_tst/com/dbcheck.csh >& dbcheck.log
