#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "#----------------------------------------------------------------------------------------------------#"
echo "# [YDB#1415] MUPIP REORG -TRUNCATE does not restart once for each killed global whose root it moves  #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# Each restart of MUPIP REORG -TRUNCATE resets the root and clue of every global that the REORG has"
echo "# accessed, so a restart for each root block moved makes the time of the REORG grow with the square"
echo "# of the number of such globals. The subtest counts the restarts (the NR0 statistic of the region)"
echo "# instead of timing the REORG."
echo

# MUPIP REORG -TRUNCATE is not supported with the MM access method so force BG
source $gtm_tst/com/gtm_test_setbgaccess.csh
# Disable V6 DB mode and the > 4g db block testing scheme as both change MUPIP REORG -TRUNCATE behavior
setenv gtm_test_use_V6_DBs 0
setenv ydb_test_4g_db_blks 0
# The globals must all be in region DEFAULT, so disable spanning region randomization
setenv gtm_test_spanreg 0
# Do not let the test system run its own concurrent reorg processes, as their restarts would add to NR0
setenv test_reorg NON_REORG

$gtm_tst/com/dbcreate.csh mumps 1

echo '# Command : $ydb_dist/yottadb -run init^ydb1415reorg, where'
sed -n '/^init/,/^\tquit/p' $gtm_tst/$tst/inref/ydb1415reorg.m | sed 's/^/#   /'
$ydb_dist/yottadb -run init^ydb1415reorg
echo '# Command : $ydb_dist/yottadb -run nr^ydb1415reorg (before the REORG)'
set before = `$ydb_dist/yottadb -run nr^ydb1415reorg`
echo '# Command : $MUPIP reorg -truncate -region DEFAULT'
$MUPIP reorg -truncate -region DEFAULT >&! reorg_truncate.out
if (0 == $status) then
	echo "PASS : MUPIP REORG -TRUNCATE exited with status 0"
else
	echo "FAIL : MUPIP REORG -TRUNCATE exited with a non-zero status, see reorg_truncate.out"
endif
echo '# Command : $ydb_dist/yottadb -run nr^ydb1415reorg (after the REORG)'
set after = `$ydb_dist/yottadb -run nr^ydb1415reorg`
@ restarts = $after - $before
echo "$restarts" > restarts.txt
echo "# Before the fix : a Debug or Release build restarted about 900 times, about once for each of the 1000"
echo "#                  globals"
echo "# With the fix   : expect fewer than 100 restarts (the number of restarts is in restarts.txt)"
if (100 > $restarts) then
	echo "PASS : fewer than 100 restarts"
else
	echo "FAIL : $restarts restarts"
endif

$gtm_tst/com/dbcheck.csh
