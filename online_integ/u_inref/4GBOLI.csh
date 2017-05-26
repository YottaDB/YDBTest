#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This subtest verifies that online integ runs fine with database files sizes >4GB.
# Note: since the database is replaced options like encrypt have no effect.
# While we are at it, and have a relatively long running online integ, run another
# to verify only one can run at a time.

$gtm_tst/com/dbcreate.csh mumps

# we use a gzipped db since it is much faster to gunzip than to load
echo "# Let's get our large database which is an augmented version of the WorldVista db"
$tst_gunzip -d < $gtm_test/big_files/online_integ/mumps.dat.${gtm_endian}.gz > mumps.dat
$MUPIP set -acc=$acc_meth -file mumps.dat # change the access method so that we exercise whatever the test intended to

if ($?gtm_test_qdbrundown) then
	if ($gtm_test_qdbrundown) then
		$MUPIP set -qdbrundown -file mumps.dat	>&! set_qdbrundown.out
	endif
endif

if ("HOST_LINUX_IX86" == $gtm_test_os_machtype) then
	# Quickly test that trying to access a >4GiB file on a 32-bit machine issues an error.
	$gtm_exe/mumps -run %XCMD 'set ^test4GMMAP=1'
	source $gtm_tst/com/gtm_test_setbgaccess.csh # Revert to BG so we can continue with the rest of the test
	$MUPIP set -acc=$acc_meth -file mumps.dat
endif

$MUPIP extend -blocks=1000 DEFAULT >&! extend.out

$echoline
echo "# Multiple updater processes start in the background"
setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_jobcnt 4
$gtm_tst/com/imptp.csh >&! imptp1.out
sleep 5 # make sure online integ has something to do

$echoline
# Do not run fast integ here since fast integ finished too fast before the second integ gets started
echo "# Start the online integ while the background updaters are active"
($MUPIP integ -online -preserve -r "*" >&! online_integ1.out & ; echo $! >! mupip1_pid.log) >&! bg_online_integ1.out
set mupip1_pid = `cat mupip1_pid.log`

sleep 1 # let the background online integ get started

echo "# Try to run another online integ in the background to verify only one can run at a time"
($MUPIP integ -online -preserve -r "*" >&! online_integ2.out & ; echo $! >! mupip2_pid.log) >&! bg_online_integ2.out
set mupip2_pid = `cat mupip2_pid.log`

echo "# Let's do a merge of a relatively large global to ensure we have plenty of realistic updates"
$GTM << EOF
merge ^MYTT=^YTT
h
EOF

sleep 5 # let online integ and the updaters do their thing

$echoline
echo "# Stop the background updaters"
$gtm_tst/com/endtp.csh >>& endtp1.out

$echoline
echo "# Wait for background online integs to complete"
# We have seen instances of INTEG taking more than 30 minutes to complete especially on boxes with slow disk access like pfloyd
# and lester. To avoid false test failures, increase the timeout to 1 hour (from previous 30 minutes). See <4GBOLI_unmatched_quote>
# for more details
$gtm_tst/com/wait_for_proc_to_die.csh $mupip1_pid 3600 >&! wait_for_OLI_die.out
if ($status) then
	echo "# `date` TEST-E-TIMEOUT waited 3600 seconds for online integ process $mupip1_pid to complete."
	echo "# Exiting the test."
	exit
endif
$gtm_tst/com/wait_for_proc_to_die.csh $mupip2_pid 3600 >>&! wait_for_OLI_die.out
if ($status) then
	echo "# `date` TEST-E-TIMEOUT waited 3600 seconds for online integ process $mupip2_pid to complete."
	echo "# Exiting the test."
	exit
endif

# Verify that one and only one online integ succeeded
$echoline
echo "# Verify MAXSSREACHED error is present."
$echoline

set online_integ1_has_it  = `$grep -c MAXSSREACHED online_integ1.out`
set online_integ2_has_it = `$grep -c MAXSSREACHED online_integ2.out`
@ num = $online_integ1_has_it + $online_integ2_has_it
if ( $num != 1 ) then
	echo "TEST FAILED - MAXSSREACHED was either not found or found in both online integs."
else
	if ( $online_integ1_has_it == 1 ) then
		set err_filename = online_integ1.out
	else
		set err_filename = online_integ2.out
	endif
	$gtm_tst/com/check_error_exist.csh $err_filename MAXSSREACHED MUNOTALLINTEG
endif
$gtm_tst/com/dbcheck.csh
