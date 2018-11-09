#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017,2018 YottaDB LLC. and/or its subsidiaries.	#
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
		# We have seen test runtimes as high as 13 hours (msreplic_H_1/max_connections) on 1-CPU armv6l
		# and 10.25 hours (msreplic_H_1/max_connections) on 4-CPU armv7l so keep max at 16 hours.
		set gtm_test_hang_alert_sec = 57600 # A subtest running for 16 hours on a 1-CPU system is suspected to be hung
	else
		# Multi-CPU x86_64 box
		set gtm_test_hang_alert_sec = 9000 # A subtest running for 2.5 hours on x86_64 boxes is suspected to be hung
	endif
endif
set mailinterval = 1800 # Send mail to the user ever 30 minutes
# Kill submit_test.csh after waiting $killtime, to let the other tests continue
@ killtime = $gtm_test_hang_alert_sec + $mailinterval

if (! $?gtm_test_max_core) then
	set gtm_test_max_core = 10
endif

cd $tst_general_dir

while !( -e $exit_file)
	set cursubtestdir = `$tst_awk '/SUB_TEST:/ {subtest=$NF} END {print subtest}' $tst_general_dir/config.log`
	if ("" == $cursubtestdir) then
		set cursubtestdir = "tmp"
		set errmsg = "Test stopped as it has too many core files"
	else
		set errmsg = "FAIL from $cursubtestdir  # Subtest stopped as it has too many core files"
	endif

	# There might be a window where the previous subtest completed (and got removed) but the next subtest's entry is not made in config.log yet
	if (! -d $cursubtestdir) then
		sleep 1
		continue
	endif
	# Job 1 : Watch for too many cores.
	cd $cursubtestdir
	set core_count = `ls -l core* |& wc -l`
	if ($gtm_test_max_core < $core_count) then
		if (0 == $teststopped) then
			# Stop the test and exit
			echo "$errmsg (Threshold = $gtm_test_max_core ; Actual = $core_count)" >>&! $tst_general_dir/outstream.log
			echo "WATCHDOG-E-CORE_COUNT. The core count ($core_count) exceed the threshold ($gtm_test_max_core). The test/subtest is stopped" >>&! gtm_test_watchdog.out
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
			# create a diff file so scripts that search for *.diff files find this failure
			echo $msg > $cursubtestdir.diff
			$gtm_tst/com/write_logs.csh FAILED
			# Capture ps/ipcs etc. at time of TEST-E-HANG report
			$gtm_tst/com/capture_ps_ipcs_netstat_lsof.csh	>& capture_ps_ipcs_netstat_lsof_HANG.out
			# Get syslog at time of TEST-E-HANG report
			set syslog_before = `cat start_time_syslog.txt`
			set syslog_after = `date +"%b %e %H:%M:%S"`
			$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog_${cursubtestdir}_HANG.txt
			cd -
			# Send TEST-E-HANG email
			echo $msg | mailx -s "TEST-E-HANG $shorthost : ${watch_dir:h}/$cursubtestdir" $mailing_list
			echo "TEST-E-HANG : $msg" >> $cursubtestdir/hangalert.out
			set mailsent = 1
		endif
		if ( $runtime >= $killtime) then
			# The test has been running for longer than $gtm_test_hang_alert_sec + extra-time.
			# Send a TEST-E-TIMEDOUT email
			#
			cd $cursubtestdir
			# Capture ps/ipcs etc. at time of TEST-E-TIMEDOUT report
			$gtm_tst/com/capture_ps_ipcs_netstat_lsof.csh	>& capture_ps_ipcs_netstat_lsof_TIMEDOUT.out
			# Get syslog at time of TEST-E-TIMEDOUT report
			set syslog_before = `cat start_time_syslog.txt`
			set syslog_after = `date +"%b %e %H:%M:%S"`
			$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog_${cursubtestdir}_TIMEDOUT.txt
			cd -
			# Kill just submit_test.csh
			cd $tst_general_dir
			set submit_test_pid = `$tst_awk '/submit_test.csh PID/ { print $NF}' $tst_general_dir/config.log`
			$kill9 $submit_test_pid
			$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk $tst_general_dir/outstream.log $outref_txt >&! $tst_general_dir/outstream.cmp
			\diff $tst_general_dir/outstream.cmp $tst_general_dir/outstream.log >& $tst_general_dir/diff.log
			# Send TEST-E-TIMEDOUT email
			$gtm_tst/com/gtm_test_sendresultmail.csh TIMEDOUT
			# Keep the generated diff.log as is that way scripts that check for failures find this abnormal event.
			# Note that it is possible the killed test runs to completion after all in which case it will
			# regenerate diff.log. If so, that is fine. But in case the test is hung eternally, we do want a
			# non-zero diff.log hence keeping this one until it gets overwritten in case the killed test completes.
			set test_killed = 1
			cd -
			touch $exit_file
		endif
	endif

	sleep 5
end

# This is reached when exit_file is found. Remove it
rm $exit_file
