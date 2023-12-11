#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
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

# This test ensures that MUPIP STOP issued to a process that has encountered an error during db_init does NOT leave the process
# in an uninterruptible state. The major part of this test would be to cause an error in db_init. This is easily achieved by
# doing a kill -9 of a GT.M process followed by removing the IPC shared memory. From now on, any process that tries to attach
# to the database will encounter REQRUNDOWN error and the process will be uninterruptible.
# Most of the following test is taken from test/v54000/u_inref/C9J08003178.csh.

# Make sure that journaling is turned off; otherwise instead of REQRUNDOWN we
# might see a different message
setenv gtm_test_jnl NON_SETJNL

$gtm_tst/com/dbcreate.csh mumps

echo
echo
$echoline
echo "Run M Program to do an update and wait for a Kill -9 to be issued"
$echoline
# Run the M program
($gtm_exe/mumps -r c003298 >&! c003298.out & ; echo $! >&! mumps_pid.log) >&! exec.out
set mumps_pid = `cat mumps_pid.log`

echo
echo
$echoline
echo "Wait for the update to complete and harden to disk"
$echoline
$gtm_exe/mumps -r waitforglobal

$gtm_exe/dse all -buff >&! flush.out

echo
echo
$echoline
echo "While the GT.M process is still attached to the shared memory, issue kill -9" # BYPASSOK
$echoline
# Kill the running GT.M instance
$kill9 $mumps_pid

# Get the shared memory id
set shmid = `$gtm_exe/mupip ftok mumps.dat |& $grep mumps | $tst_awk '{print $6}'`

# Cleanup the shared memory identifier
echo
echo
$echoline
echo "Remove the shared memory so that the next attempt on database initialization would cause REQRUNDOWN error"
$echoline
$gtm_tst/com/ipcrm -m $shmid
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl1.logx

# Try running M pogram again. It should issue REQRUNDOWN error.
echo
echo
$echoline
echo "Attempt attaching to AREG would issue REQRUNDOWN error."
$echoline
($gtm_exe/mumps -r c003298 >&! c003298_2.out & ; echo $! >&! mumps_pid2.log) >&! exec2.out
$gtm_tst/com/wait_for_log.csh -log c003298_2.out -message REQRUNDOWN
$gtm_tst/com/check_error_exist.csh c003298_2.out REQRUNDOWN ENO >&! err_capture.outx
set stat = $status
if !($stat) then
	# Issue MUPIP STOP. Prior to V5.4-002, the MUPIP STOP will never be honored by the GT.M process.
	# With V5.4-002, one should see the MUPIP STOP being honored and the process shutting down gracefully.
	echo
	echo
	$echoline
	echo "Issue MUPIP STOP to the process and see if it gets interrupted"
	$echoline
	set pid = `cat mumps_pid2.log`
	$MUPIP STOP $pid
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 20
	if ($status) then
		echo "# `date` TEST-E-FAILED: GT.M process $pid did NOT die after 20 seconds on encountering MUPIP STOP"
		echo "# Exiting the test now."
		exit 1
	endif
	# The previous error check in c003298_2.out would have moved the file to c003298_2.outx. So, check the
	# error message FORECDHALT in c003298_2.outx
	$gtm_tst/com/check_error_exist.csh c003298_2.outx FORCEDHALT
else
	echo "TEST-E-FAILED: REQRUNDOWN error is expected at this point but did not see one"
endif

echo
echo
# Rundown database so that we don't leave any semaphores behind.
$MUPIP rundown -reg "*"
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl2.logx

$gtm_tst/com/dbcheck.csh
