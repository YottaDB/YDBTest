#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set watch_dir = $1
set exit_file = $1/watchdog_${testname}.stop

set teststopped = 0
set shorthost = $HOST:r:r:r:r
set format="%Y.%m.%d.%H.%M.%S.%Z"
set timestart = `date +"$format"`
if (! $?gtm_test_hang_alert_sec) then
	if ($gtm_test_singlecpu || ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) || ("HOST_LINUX_AARCH64" == $gtm_test_os_machtype)) then
		# 1-CPU armv7l/armv6l/x86_64 box or a Multi-CPU armv7l/armv6l box. Set a high hang alert.
		# We have seen test runtimes as high as 21 hours (msreplic_H_1/max_connections) on 1-CPU armv6l
		# and 10.25 hours (msreplic_H_1/max_connections) on 4-CPU armv7l so keep max at 24 hours.
		set gtm_test_hang_alert_sec = 86400 # A subtest running for 24 hours on a 1-CPU system is suspected to be hung
	else
		# Multi-CPU x86_64 box
		# A subtest running for 5 hours on x86_64 boxes is suspected to be hung
		# Usually 2.5 hours on x86_64 boxes is enough but with -encrypt we have seen tests take 4 hours.
		set gtm_test_hang_alert_sec = 18000
	endif
endif
set mailinterval = 1800 # Send TIMEDOUT mail to the user 30 minutes AFTER TEST-E-HANG email
# Kill submit_test.csh after waiting $killtime, to let the other tests continue
@ killtime = $gtm_test_hang_alert_sec + $mailinterval

if (! $?gtm_test_max_core) then
	set gtm_test_max_core = 10
endif

cd $tst_general_dir

while !( -e $exit_file)
	sleep 0.1
	set cursubtestdir = `$tst_awk '/SUB_TEST:/ {subtest=$NF} END {print subtest}' $tst_general_dir/config.log`
	if ("" == $cursubtestdir) then
		set cursubtestdir = "tmp"
		set errmsg = "Test stopped as it has too many core files"
	else
		set errmsg = "FAIL from $cursubtestdir  # Subtest stopped as it has too many core files"
	endif

	# There might be a window where the previous subtest completed (and got removed) but the next subtest's entry is not made in config.log yet
	if (! -d $cursubtestdir) then
		continue
	endif
	# Job 1 : Watch for too many cores.
	cd $cursubtestdir
	set core_count = `ls -l core* |& wc -l`
	if ($gtm_test_max_core < $core_count) then
		if (0 == $teststopped) then
			# Stop the test and exit
			echo "$errmsg (Threshold = $gtm_test_max_core ; Actual = $core_count)" >>&! $tst_general_dir/outstream.log
			set msg = "WATCHDOG-E-CORE_COUNT : ${watch_dir:h:t}/$cursubtestdir stopped as it has too many core files"
			echo "$msg" >>&! gtm_test_watchdog.out
			# create a diff file so scripts that search for *.diff files to detect failure treat this subtest as failed
			echo "$msg" > $cursubtestdir.diff
			$gtm_tst/com/stoptest.csh
			set teststopped=1
		endif
	else
		set teststopped = 0
	endif
	cd -

	# Job 2 : Watch for too long running test.
	if (! $?test_killed) then
		if (-e $tst_general_dir/timing.subtest) then
			set timestart = `$tst_awk '{t=$7} END {print t}' $tst_general_dir/timing.subtest`
		endif
		set timenow = `date +"$format"`
		set runtime =  `echo $timestart.$timenow | $tst_awk -F \. -f $gtm_tst/com/diff_time.awk`
		if ( ( $runtime >= $gtm_test_hang_alert_sec ) && (! $?mailsent) ) then
			# The test has been running for longer than $gtm_test_hang_alert_sec.
			# Send a TEST-E-HANG email
			#
			set msg = "${watch_dir:h:t}/$cursubtestdir has been running for $runtime seconds. Check if it is hung"
			cd $cursubtestdir
			echo $msg > hangalert_email.txt
			# create a diff file so scripts that search for *.diff files to detect failure treat this subtest as failed
			echo $msg > $cursubtestdir.diff
			# "test_time" env var is needed by the following "write_logs.csh" invocation.
			setenv test_time  `echo $timestart.$timenow | $tst_awk -F \. -f $gtm_tst/com/diff_time.awk -v full=1`
			$gtm_tst/com/write_logs.csh FAILED
			# The above "write_logs.csh" invocation would have updated "report.txt".
			echo "" >> hangalert_email.txt
			echo "Random options chosen :" >> hangalert_email.txt
			$grep -w $testname $tst_dir/$gtm_tst_out/report.txt >> hangalert_email.txt
			# Capture ps/ipcs etc. at time of TEST-E-HANG report
			$gtm_tst/com/capture_ps_ipcs_ss_lsof.csh	>& capture_ps_ipcs_ss_lsof_HANG.out
			# Get syslog at time of TEST-E-HANG report
			set syslog_before = `cat start_time_syslog.txt`
			set syslog_after = `date +"%b %e %H:%M:%S"`
			$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog_${cursubtestdir}_HANG.txt
			# Copy settings.csh to debuglogs
			if (-e settings.csh) cp settings.csh $gtm_test_debuglogs_dir/${testname}_${cursubtestdir}_HANG_settings.csh
			# Send TEST-E-HANG email
			mailx -s "TEST-E-HANG $shorthost : ${watch_dir:h}/$cursubtestdir" $mailing_list < hangalert_email.txt
			set mailsent = 1
			echo "TEST-E-HANG : $msg" >> hangalert.out
			cd -
		endif
		if ( $runtime >= $killtime) then
			# The test has been running for longer than $gtm_test_hang_alert_sec + extra-time.
			# Send a TEST-E-TIMEDOUT email
			#
			cd $cursubtestdir
			# Capture ps/ipcs etc. at time of TEST-E-TIMEDOUT report
			$gtm_tst/com/capture_ps_ipcs_ss_lsof.csh	>& capture_ps_ipcs_ss_lsof_TIMEDOUT.out
			# Get syslog at time of TEST-E-TIMEDOUT report
			set syslog_before = `cat start_time_syslog.txt`
			set syslog_after = `date +"%b %e %H:%M:%S"`
			$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog_${cursubtestdir}_TIMEDOUT.txt
			# Copy settings.csh to debuglogs
			if (-e settings.csh) cp settings.csh $gtm_test_debuglogs_dir/${testname}_${cursubtestdir}_TIMEDOUT_settings.csh
			cd -
			# --------------------------------------------------
			# At this point submit_test.csh is hung. We expect it to be hung for a bit more.
			# So keep that process alive and generate artifacts to record the fact that the test hung/failed.
			# And then finally kill submit_test.csh but not its child which is <test>/instream.csh.
			# This way the script that submitted a bunch of submit_test.csh commands (to correspond to
			# a list of tests that need to be run) can move on to the next submit_test.csh call while still
			# letting this hung test run in the background (for debugging/analysis of the hang).
			# --------------------------------------------------
			# Generate diff.log
			echo "FAIL from $cursubtestdir. Please check $cursubtestdir/$cursubtestdir.diff" >> outstream.log
			mv outstream.cmp outstream.cmp.original
			head -1 $tst_general_dir/outstream.log | grep -iE "tests? (start|begin)"	> outstream.cmp
			cat outstream.cmp.original							>> outstream.cmp
			\diff outstream.cmp outstream.log >& diff.log
			# Keep the generated diff.log as is that way scripts that check for failures find this abnormal event.
			# Note that it is possible the killed test runs to completion after all in which case it will
			# regenerate diff.log. If so, that is fine. But in case the test is hung eternally, we do want a
			# non-zero diff.log hence keeping this one until it gets overwritten in case the killed test completes.

			# Given that submit_test.csh is going to be killed, complete what it would have done to record the fact
			# that 1 subtest failed/hung in case a final report email is going to be sent.
			set st_passed   = `$grep -c "PASS from" outstream.log`
			set st_failed   = `$grep -c "FAIL from" outstream.log`
			set st_hung     = 1		# we know at least one subtest hung so record that
			set st_disabled = `$grep -wc "$testname" $gtm_test_local_debugdir/excluded_subtests.list`
			echo "$testname	$st_passed	$st_failed	$st_hung	$st_disabled" >> $gtm_test_local_debugdir/test_subtest.info
			# Send TEST-E-TIMEDOUT email
			$gtm_tst/com/gtm_test_sendresultmail.csh TIMEDOUT
			# Kill submit_test.csh finally now that all artifacts to record this hang/failure have been generated.
			set submit_test_pid = `$tst_awk '/submit_test.csh PID/ { print $NF}' config.log`
			$kill9 $submit_test_pid
			# --------------------------------------------------
			set test_killed = 1
			touch $exit_file
		endif
	endif
end

# This is reached when exit_file is found. Remove it
rm $exit_file
