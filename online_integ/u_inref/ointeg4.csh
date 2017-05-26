#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This subtest verifies that online integ runs fine with multiple updaters and multiple regions

$gtm_tst/com/dbcreate.csh mumps 4 255 1000 -allocation=2048 -extension_count=2048

$echoline
echo "# Multiple updater processes start in the background"
setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_jobcnt 4
$gtm_tst/com/imptp.csh >&! imptp1.out
sleep 30 # make sure online integ has something to do

$echoline
echo "# Start the online integ while the background updaters are active"
($MUPIP integ $FASTINTEG -online -preserve -r "*" >&! online_integ.out & ; echo $! >! mupip1_pid.log) >&! bg_online_integ.out
set mupip1_pid = `cat mupip1_pid.log`

sleep 30 # let online integ and the updaters do their thing

$echoline
echo "# Stop the background updaters"
$gtm_tst/com/endtp.csh >>& endtp1.out

$echoline
echo "# Wait for background online integ to complete"
$gtm_tst/com/wait_for_proc_to_die.csh $mupip1_pid 120 >&! wait_for_OLI_die.out
if ($status) then
	echo "# `date` TEST-E-TIMEOUT waited 120 seconds for online integ $mupip1_pid to complete."
	echo "# Exiting the test."
	exit
endif

$gtm_tst/com/dbcheck.csh
