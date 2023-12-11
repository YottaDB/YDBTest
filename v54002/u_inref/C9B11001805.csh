#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Turn off statshare related env var as it causes an assert failure "sr_unix/gds_rundown.c line 880 for expression (0 == rc)"
# and is most definitely due to removing the .dat files (but not removing the corresponding .dat.gst statsdb file)
# while the source server is still running.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

setenv gtm_test_jnl "SETJNL"

echo "Test 1. Two MUMPS processes with the same uid."
echo "Creating the database"
$gtm_tst/com/dbcreate.csh mumps

$gtm_exe/dse >& "dse.outx" << EOF
        change -fileheader -flush_time=100000
        quit
EOF

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 45

echo "Starting the first MUMPS process"
($gtm_exe/mumps -run %XCMD 'set ^a=1  view "JNLWAIT"' >&! simplewrite10.out & ; echo $! >! mumps10_pid.log) >&! bg_process10.out
$gtm_tst/com/wait_for_log.csh -log mumps10_pid.log
set pid_1 = `cat mumps10_pid.log`
$gtm_tst/com/wait_for_log.csh -log simplewrite10.out -message "JNL_FSYNC: will sleep for 40 seconds"
echo "Issuing a SIGSTOP to simulate a possibly stopped process and expect that the process waiting for the jnl_fsync_in_prog latch will attempt firing a SIGCONT at half-timeout."
kill -s STOP $pid_1

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number

echo "Starting the second MUMPS process"
($gtm_exe/mumps -run %XCMD 'set ^b=1  view "JNLWAIT"' >&! simplewrite11.out & ; echo $! >! mumps11_pid.log) >&! bg_process11.out
$gtm_tst/com/wait_for_log.csh -log mumps11_pid.log
set pid_2 = `cat mumps11_pid.log`
$gtm_tst/com/wait_for_proc_to_die.csh $pid_2 240

ls "JNLFSYNCSTUCK_HALF_TIME_${pid_2}_${pid_1}.outx" >& /dev/null
if (0 == $status) then
	mv "JNLFSYNCSTUCK_HALF_TIME_${pid_2}_${pid_1}.outx" "1_JNLFSYNCSTUCK_HALF_TIME_${pid_2}_${pid_1}.outx"
endif
$gtm_tst/com/dbcheck.csh
rm mumps.dat

echo
echo

echo "Test 2. Two MUMPS processes with different uids."
echo "Creating the database"
$gtm_tst/com/dbcreate.csh mumps

$gtm_exe/dse >& "dse.outx" << EOF
        change -fileheader -flush_time=100000
        quit
EOF

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 45

echo "Starting the first MUMPS process"
($gtm_exe/mumps -run %XCMD 'set ^a=1  view "JNLWAIT"' >&! simplewrite20.out & ; echo $! >! mumps20_pid.log) >&! bg_process20.out
$gtm_tst/com/wait_for_log.csh -log mumps20_pid.log
set pid_1 = `cat mumps20_pid.log`
$gtm_tst/com/wait_for_log.csh -log simplewrite20.out -message "JNL_FSYNC: will sleep for 40 seconds"
echo "Issuing a SIGSTOP to simulate a possibly stopped process and expect that the process waiting for the jnl_fsync_in_prog latch will attempt firing a SIGCONT at half-timeout."
kill -s STOP $pid_1

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number

echo "Launching remote process with different uid"
set ver = `basename $gtm_ver`
set img = `basename $gtm_dist`
source $gtm_tst/com/set_specific.csh
$gtm_tst/com/send_env.csh
if ("ENCRYPT" == "$test_encryption") then
        $gtm_tst/com/encrypt_for_gtmtest1.csh mumps_dat_key mumps_remote_dat_key
endif
$rsh $tst_org_host -l $gtmtest1 $gtm_tst/$tst/u_inref/remote_user.csh $ver $img $tst_working_dir $gtm_tst >&! remote_user.log
$gtm_tst/com/wait_for_log.csh -log remote_user.log -message "Done testing" -duration 200
set pid_2 = `cat mumps21_pid.log`
ls "JNLFSYNCSTUCK_HALF_TIME_${pid_2}_${pid_1}.outx" >& /dev/null
if (0 == $status) then
	mv "JNLFSYNCSTUCK_HALF_TIME_${pid_2}_${pid_1}.outx" "2_JNLFSYNCSTUCK_HALF_TIME_${pid_2}_${pid_1}.outx"
endif
$gtm_tst/com/dbcheck.csh
