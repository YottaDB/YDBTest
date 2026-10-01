#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps
echo "# This test simulates, via a white-box logic, an error return from timer_create()/setitimer(), which is used to"
echo "# start a new system timer or cancel an existing one. We expect appropriate error messages to be printed in the console."
echo "# Each %YDB-E-SYSCALL for timer_settime() must carry the timer state as a %YDB-I-TEXT. No fork happens here, so that state"
echo "# must say posix_timer_created is 1, fork_after_ydb_init is 0, process_id is getpid(), posix_timer_thread_id is gettid()"
echo "# and time_to_expir is a valid expiry time. setitimer_fail_check.awk checks this and prints PASS or WRONG per message."

echo "# Set the white-box test that simulates an error return from timer_create()/setitimer()."
set echo
setenv ydb_white_box_test_case_enable 1
setenv ydb_white_box_test_case_number 98
unset echo

echo "##################################################################"
echo "# Case 1. A timer_create()/setitimer() failure from direct mode. #"
echo "##################################################################"
$echoline

echo "# Try to do a database update from direct mode, thus starting a timer and invoking the white-box test logic."
echo "# Run [mumps -direct >& case1.out] and type [set ^x=1] and [quit]"
$ydb_dist/mumps -direct >&! case1.out <<EOF
set ^x=1
quit
EOF
$gtm_tst/com/check_error_exist.csh case1.out "%YDB-E-SYSCALL" "%SYSTEM-E-ENO22" "%YDB-E-LKRUNDOWN" | $tst_awk '{gsub(/posix_timer_thread_id: [0-9]+/, "posix_timer_thread_id: ##PID##"); gsub(/gettid\(\): [0-9]+/, "gettid(): ##PID##"); gsub(/process_id: [0-9]+/, "process_id: ##PID##"); gsub(/getpid\(\): [0-9]+/, "getpid(): ##PID##"); print}'
echo "# Check the timer state reported with each timer_settime() error in case1.out"
$tst_awk -f $gtm_tst/$tst/inref/setitimer_fail_check.awk case1.outx

echo

echo "###################################################################"
echo "# Case 2. A timer_create()/setitimer() failure from an M routine. #"
echo "###################################################################"
$echoline

echo "# Produce a simple M file test.m for testing."
cat <<EOF >&! test.m
test
	set ^x=2
	quit
EOF

echo "# Invoke the M program with a database update, thus starting a timer and triggering the white-box test logic."
echo "# Run [mumps -run test >& case2.out]"
$ydb_dist/mumps -run test >&! case2.out
$gtm_tst/com/check_error_exist.csh case2.out "%YDB-E-SYSCALL" "%SYSTEM-E-ENO22" "%YDB-E-LKRUNDOWN" | $tst_awk '{gsub(/posix_timer_thread_id: [0-9]+/, "posix_timer_thread_id: ##PID##"); gsub(/gettid\(\): [0-9]+/, "gettid(): ##PID##"); gsub(/process_id: [0-9]+/, "process_id: ##PID##"); gsub(/getpid\(\): [0-9]+/, "getpid(): ##PID##"); print}'
echo "# Check the timer state reported with each timer_settime() error in case2.out"
$tst_awk -f $gtm_tst/$tst/inref/setitimer_fail_check.awk case2.outx

unsetenv ydb_white_box_test_case_enable
$gtm_tst/com/dbcheck.csh
