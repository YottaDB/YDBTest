#! /usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2010, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2021-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

echo "Testing D9D12002400"

# Create database
$gtm_tst/com/dbcreate.csh mumps

# Turn on journaling.  Using a low autoswitchlimit so the journal file switch happens faster.
$MUPIP set -journal=enable,on,before,autoswitchlimit=16384 -reg DEFAULT

# A sub script is used so the background process information isn't printed in the output.
cat > crash.csh << EOF
#!/usr/local/bin/tcsh
setenv gtm_white_box_test_case_number 41
setenv gtm_white_box_test_case_enable 1
$gtm_exe/mumps -run %XCMD 'for  set ^a=\$increment(i)' >&! mumps.out &
set pid=\`echo \$!\`
# Wait for the message that indicates that GT.M hit the white box test (in cre_jnl_file.c), where it will sleep for 600 seconds.
# Note that to hit that point in cre_jnl_file, the test has to fill up one journal file and switch it.
# Even though we choose the lowest possible autoswitchlimit in this test (8MiB), it has been seen to take
# more than half an hour on the ARMV6L architecture so wait for a max of 1 hour (3600 seconds) for that step to be reached.
$gtm_tst/com/wait_for_log.csh -log mumps.out -message "CRE_JNL_FILE: started a wait" -duration 3600
$kill9 \$pid
EOF

# Kill GT.M during the journal file creation process, once the new journal file has been renamed.
chmod +x crash.csh
./crash.csh >& crash.txt

# This test does kill -9 followed by a MUPIP JOURNAL -RECOVER. A kill -9 could hit the running GT.M process while it
# is in the middle of executing wcs_wtstart. This could potentially leave some dirty buffers hanging in the shared
# memory. So, set the white box test case to avoid asserts in wcs_flu.c
setenv gtm_white_box_test_case_number 29
setenv gtm_white_box_test_case_enable 1
# Recover the database.
$MUPIP journal -recover -backward '*'

$MUPIP rundown -relinkctl >&! mupip_rundown_rctl.logx

# Check DB integrity.
$gtm_tst/com/dbcheck.csh
