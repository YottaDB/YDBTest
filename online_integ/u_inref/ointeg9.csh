#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test that an ongoing MUPIP INTEG on encountering a signal (that can be handled in UNIX), the temporary snapshot files
# are cleaned up automatically.

$gtm_tst/com/dbcreate.csh mumps

# we use a gzipped db since it is much faster to gunzip than to load
echo ""
$echoline
echo "# Let's get our large database which is an augmented version of the WorldVista db"
$echoline
$tst_gunzip -d < $gtm_test/big_files/online_integ/mumps.dat.${gtm_endian}.gz > mumps.dat
if (("HOST_LINUX_IX86" != $gtm_test_os_machtype)		\
	&& ("HOST_OSF1_ALPHA" != $gtm_test_os_machtype)		\
	&& ("HOST_HP-UX_PA_RISC" != $gtm_test_os_machtype)) then
	# change the access method so that we exercise whatever the test intended to
	$MUPIP set -acc=$acc_meth -file mumps.dat
endif

set sleeptime = `$gtm_exe/mumps -run rand 10`
set timestamp = `date +%H%M%S`
set attempt = 1
while ($attempt <= 4)
	set outfile = "try_online_integ_$attempt"
	echo "Sleep time = $sleeptime"									>>&! $outfile
	echo ""												>>&! $outfile
	$echoline											>>&! $outfile
	echo "Start ONLINE INTEG in the background"							>>&! $outfile
	$echoline											>>&! $outfile
	# We do not run integ -fast here since integ -fast will be completed before KILL -15
	($MUPIP integ -online -r -dbg "*" >&! online_integ_$attempt.out & ; echo $! >! mupip1_pid.log)  >>&! $outfile
	set mupip1_pid = `cat mupip1_pid.log`
	cp mupip1_pid.log{,$attempt}

	# Wait for the code to reach at least a point where the signal handlers are established. This is needed as otherwise,
	# if the sleep time is too small, then we might issue a SIGTERM even before the MUPIP has completed establishing
	# signal handlers and hence there is no point in issuing the SIGTERM in the first place.
	$gtm_tst/com/wait_for_log.csh -message "Integ of region DEFAULT" -log "online_integ_$attempt.out" -duration 60

	sleep $sleeptime # Let the background online integ get started and run for few secs

	echo ""												>>&! $outfile
	$echoline											>>&! $outfile
	echo "Now that ONLINE INTEG is running for sometime, issue SIGTERM"				>>&! $outfile
	$echoline											>>&! $outfile
	$kill -15 $mupip1_pid 										>>&! $outfile
	set stat = $status
	if ($stat) then
		# This means, the INTEG should have completed even before the KILL was attempted.
		# Verify we have a clean INTEG
		$grep "No errors detected by integ" online_integ_$attempt.out				>>&! $outfile
		set stat = $status
		if ($stat) then
			echo "TEST-E-FAIL, Integ completed before KILL -15 but yet failed. Check online_integ_$attempt.out"
			exit 1		# No point continuing
		endif
	else
		# Kill succeeded. Wait for the MUPIP process to die
		$gtm_tst/com/wait_for_proc_to_die.csh $mupip1_pid 1200 >&! wait_for_OLI_die_$attempt.out
		if ($status) then
			echo "# `date` TEST-E-TIMEOUT waited 1200 seconds for online integ $mupip1_pid to complete."
			echo "Exiting the test."
			exit 1
		endif
		$grep -q FORCEDHALT online_integ_$attempt.out
		if (0 == $status) break		# We are done.
	endif
	# We just got unlucky. Reduce sleep time and re-run INTEG
	@ sleeptime /= 2
	if (0 == $sleeptime) then
		echo "TEST-E-FAIL, Sleeptime is zero. No more retries"
		exit 1
	endif
	@ attempt++
end

if !( -e online_integ_$attempt.out ) then
	# None of the kill attempts succeeded. This has been known to happen on fast boxes
	echo "TEST-E-FAIL, Loop exited without killing ONLINE INTEG"
	$grep -E '^kill|Sleep' try_online_integ_*
	exit 1		# No point continuing
endif
\mv online_integ_$attempt.out online_integ_final.out # For consistent output
echo ""
$gtm_tst/com/check_error_exist.csh online_integ_final.out FORCEDHALT

echo ""
$echoline
ls -l ydb_snapshot* >&! ls_ydb_snapshot.log
set stat = $status
if ($stat) then
	echo "Snapshot files not found AS EXPECTED"
else
	echo "TEST-E-FAILED : Snapshot files were found"
endif
$gtm_tst/com/dbcheck.csh
