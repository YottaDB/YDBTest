#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2011, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This subtest validates the changes in handling timer events that are triggered while in a
# no-interrupt section of the code. Different scenarios below exercise how timer event delivery
# works in combination with or without interrupts.
#
# Task 1. Deferred timers execution.
#
# In this task two flush timers pop while in a non-interruptable window, and handled upon leaving
# that window.
#
# The flush timers are started when set ^a=1 and set ^z=1 commands are executed; and hang 123
# ends up invoking a 20-second sleep within a timer-deferred window. Before the original state is
# restored, both flush timers should pop, since they are set for 5 and 8 seconds correspondingly,
# and then handled upon leaving the timer-deferred window.

echo "Task 1. Starting deferred timer execution test..."
echo "--------------------------------------------"

setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates (done in set_up_db.csh) done in the same subtest
$gtm_tst/$tst/u_inref/set_up_db.csh 500 800

# setting these here to prevent extra processing in the source code
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 53
setenv gtm_white_box_test_case_count 1

echo "Starting MUMPS process in the foreground..."
$gtm_dist/mumps -direct << EOF
	set ^a=1
	set ^z=1
	hang 123
	hang 10
	halt
EOF

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_count

# dbcreate is done in set_up_db.csh
$gtm_tst/com/dbcheck.csh

$gtm_tst/$tst/u_inref/back_up_db.csh 1

echo

# Task 2. Deferred timers cancellation.
#
# In this task a flush timer pops, followed by a MUPIP STOP interrupt, followed by another flush
# timer pop---all while in a non-interruptable window. Upon leaving that window, the flush timers
# are canceled, and the MUPIP STOP interrupt is handled.
#
# We first launch a job in the background that does two sets, thus starting two flush timers. Then
# a hang causes the process to enter a timer-deferred zone with a 20-second sleep. As soon as the
# sleep is initiated, we issue a MUPIP STOP on the process, which cannot be handled immediately,
# because interrupt-processing is also deferred. When timers and interrupts are reenabled, the
# two deferred timers are canceled due to the MUPIP STOP logic.

echo "Task 2. Starting deferred timer cancel test..."
echo "--------------------------------------------"

setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates (done in set_up_db.csh) done in the same subtest
$gtm_tst/$tst/u_inref/set_up_db.csh 700 1500

# setting these here to prevent extra processing in the source code
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 53
setenv gtm_white_box_test_case_count 2

echo "Starting MUMPS process in the background..."
( $gtm_tst/$tst/u_inref/write_updates.csh &) >& gtm.outx

$gtm_tst/com/wait_for_log.csh -log gtm.outx -message "OP_HANG: will sleep for 20 seconds"

set pid = `cat pid.outx`

echo "Issuing a MUPIP STOP to MUMPS process..."
$gtm_dist/mupip stop $pid >& mupip_stop.outx

$gtm_tst/com/wait_for_log.csh -log gtm.outx -message "Timers canceled:"

cat gtm.outx

$gtm_tst/com/wait_for_proc_to_die.csh $pid -1        # indefinite wait

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_count

# dbcreate is done in set_up_db.csh
$gtm_tst/com/dbcheck.csh

$gtm_tst/$tst/u_inref/back_up_db.csh 2
