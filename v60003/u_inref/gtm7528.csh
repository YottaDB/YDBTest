#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv test_encryption "NON_ENCRYPT" # There is a FTOK semaphore release/grab during encryption which
				     # messes up the whitebox test case
# With 16K counter semaphore bump per process, the 32K counter overflow happens with two mumps processes
# that this test starts and so the white-box code in db_init which is exercised by the later TWO dse invocations
# does not see the counter at 3 or 4 like it expects and defeats the purpose of the test. It is not easy to
# design the white-box code to work with a 16K counter semaphore bump so prevent counter overflow by setting
# the increment value to default value of 1 (aka unset).
unsetenv gtm_db_counter_sem_incr

$gtm_tst/com/dbcreate.csh mumps 1 125 1000 4096 2000 4096 2000 >&! dbcreate.out

setenv gtm_test_jobid 1
setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_jobcnt 2

setenv gtm_white_box_test_case_count `$gtm_exe/mumps -run %XCMD 'write $random(2)'`

echo "# Is db_init() retry limit is reduced to 1? [1 if yes, 0 otherwise]: $gtm_white_box_test_case_count"

echo "# Launching $gtm_test_jobcnt jobs."
$gtm_tst/com/imptp.csh >& imptp.out
# Make sure each process made at least 1 update
$GTM <<EOF
    for i=1:1:300 quit:(\$get(^lasti(0,1))>0)&(\$get(^lasti(0,2))>0)  hang 1
EOF
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 96 # WBTEST_HOLD_FTOK_UNTIL_BYPASS

echo "# Launching a DSE process which will hold the ftok semaphore"
($DSE dump -nocrit >& dse1_out &)
$gtm_tst/com/wait_for_log.csh -log dse1_out -message "Holding the ftok semaphore until a new process comes along" -duration 300
echo "# Launching another DSE process which will bypass the ftok semaphore"
set syslog_before = `date +"%b %e %H:%M:%S"`
($DSE dump -nocrit >& dse2_out &)
$gtm_tst/com/getoper.csh "$syslog_before" "" syslog1.txt "" "RESRCWAIT" # Make sure FTOK bypass occurred
$gtm_tst/com/wait_for_log.csh -log dse2_out -message "Waiting for all processes to quit" -duration 300
unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
echo "# Stopping mumps processes"
$gtm_tst/com/endtp.csh >& endtp.out
echo "# Bypasser DSE process should continue with db_init. Verify if this is done"
$gtm_tst/com/wait_for_log.csh -log dse2_out -message "REGOPENRETRY" -duration 300
if (1 == $gtm_white_box_test_case_count) then
    $gtm_tst/com/wait_for_log.csh -log dse2_out -message "REGOPENFAIL" -duration 300
endif
$gtm_tst/com/dbcheck.csh
