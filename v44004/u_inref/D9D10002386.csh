#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# D9D10-002386 resync_seqno does not get flushed to disk by source server if GTM is inactive
#
# the flow of the test:
# check the resync seqno information from the shm (output of a -jnlpool -show) and disk (replication instance file).
# now the resync seqno is per instance, so no need to check per region.

#################################
# remove/modify....
# 1. Maintain multiple (at least 3) regions, update one of them,
#
# 2. Wait for 90 seconds, and notice the resync_seqno, and in addition RESYNC SEQNO as read from disk is exactly
# as read from shm (flush when necessary, during idle).
#
# While the Source Server's flush header timeout is 60 sec, compression makes it easy to exceed that timeout - the
# Source Server is stuck in compression routines for more than 60 seconds. Recent changes have decreased the
# opportunities to flush, so we're bumping this to 90 seconds. <resync_seq_no_flush_timing_issue>
#
# 3. Create enough backlog that source will take longer than 60s to clear backlog. After 90s of clearing backlog,
# notice that on disk RESYNC SEQNO is less than or equal to that in shm, and the RESYNC SEQNO from disk gets
# updated (flush when necessary, during activity)
#
# 4. 60 seconds after backlog is cleared, note down the file mod time; wait for another 60 seconds, notice that
# the file mod time doesn't change (don't flush when not necessary)
#################################
#
# MREP <resync_seq_no_flush_timing_issue> high compression levels delay file header flushes. Lower it
if ($?gtm_zlib_cmp_level) then
	if ($gtm_zlib_cmp_level > 6) then
		$echoline  >> settings.csh
		echo "Drop compression level from $gtm_zlib_cmp_level to 6"  >> settings.csh
		echo "setenv gtm_zlib_cmp_level 6" >> settings.csh
		setenv gtm_zlib_cmp_level 6
	endif
endif

# This is a timing sensitive test, avoid freezing
unsetenv gtm_test_freeze_on_error
unsetenv gtm_test_fake_enospc

$gtm_tst/com/dbcreate.csh mumps 3 125 1000 -allocation=2048 -extension_count=2048

setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
set test_sleep_time=100
set test_resync_flush_sleep_time=90

echo "#######################################################################################"
# update one region
echo "#Update region A"
echo "###########"
echo "GTM_TEST_DEBUGINFO: "`date`
$gtm_dist/mumps -run d002386
echo "GTM_TEST_DEBUGINFO: "`date`
$MUPIP replic -source -showbacklog >& check_srcbacklog.out
set cur_backlog = `$gtm_tst/com/compute_src_backlog_from_showbacklog_file.csh check_srcbacklog.out`
if ( $cur_backlog > 0) then
	@ lim_backlog = $cur_backlog - 1
	# check if the source server has send some data to the receiver
	set timeout = 30
	$gtm_tst/com/wait_until_src_backlog_below.csh $lim_backlog $timeout
	if ($status != 0) then
		echo "TEST-E-TIMEOUT, it took too long to send data from source server to receive server."
	endif
endif
echo "###########"
echo "GTM_TEST_DEBUGINFO: "`date`
# check resync_seqno from disk
echo "#resync seqno right after the update"
set shm_resync1 = `$gtm_tst/$tst/u_inref/get_resync_seqno.csh SHM`
set shm_resync1_slt = `$gtm_tst/$tst/u_inref/get_resync_seqno.csh SHM SLT`
set disk_resync1 = `$gtm_tst/$tst/u_inref/get_resync_seqno.csh DISK`
echo "#shm_resync1 is: 	GTM_TEST_DEBUGINFO: $shm_resync1"
echo "#disk_resync1 is:	GTM_TEST_DEBUGINFO: $disk_resync1"
echo "#shm_resync1_slt is: 	GTM_TEST_DEBUGINFO: $shm_resync1_slt"

if ($shm_resync1 <= 1) then
	echo "TEST-E-NOSYNC shm_resync1 ($shm_resync1) not updated."
endif

echo "#######################################################################################"
echo "###########"
echo "#After $test_resync_flush_sleep_time seconds of inactivity"
echo "#The resync seqno from shared memory (-jnlpool -show) should be the same as the resync seqno from the replication instance file."
@ sleepfor = $test_resync_flush_sleep_time
while (0 < $sleepfor)
	set shm_resync2 = `$gtm_tst/$tst/u_inref/get_resync_seqno.csh SHM`
	set shm_resync2_slt = `$gtm_tst/$tst/u_inref/get_resync_seqno.csh SHM SLT`
	set disk_resync2 = `$gtm_tst/$tst/u_inref/get_resync_seqno.csh DISK`
	sleep 1
	@ sleepfor--
	if (($shm_resync2 == $disk_resync2) && ($shm_resync2_slt == $disk_resync2)) then
		@ sleepfor = 0
	endif
end
echo "GTM_TEST_DEBUGINFO: "`date`
echo "#shm_resync2 is: 	GTM_TEST_DEBUGINFO: $shm_resync2"
echo "#disk_resync2 is:	GTM_TEST_DEBUGINFO: $disk_resync2"
echo "#shm_resync2_slt is: 	GTM_TEST_DEBUGINFO: $shm_resync2_slt"

# compare the resync seqno from shm and disk
if ($shm_resync2 != $disk_resync2) then
	echo "TEST-E-NOFLUSH, the resync seqno from shm is not the same from disk."
	echo "shm_resync2: $shm_resync2"
	echo "disk_resync2: $disk_resync2"
endif

if ($shm_resync2_slt != $disk_resync2) then
	echo "TEST-E-UNEQUAL shm_resync2_slt: $shm_resync2_slt vs disk_resync2: $disk_resync2"
endif

echo "#######################################################################################"
# force down the receiver server to create backlog
echo "#Shut down the receiver server to create backlog"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
echo "GTM_TEST_DEBUGINFO: "`date`
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep $test_sleep_time
echo "GTM_TEST_DEBUGINFO: "`date`

# stop the background M process
echo "#Stop the background GTM process"
$gtm_tst/com/endtp.csh
echo "GTM_TEST_DEBUGINFO: "`date`

$MUPIP replic -source -showbacklog >& check_srcbacklog2.out
set cur_backlog = `$gtm_tst/com/compute_src_backlog_from_showbacklog_file.csh check_srcbacklog2.out`
@ lim_backlog = $cur_backlog - 1

# start receiver server to clear the backlog
echo "#Start the receiver server to clear the backlog"
set start_time=`date +%H_%M_%S`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""on"" $portno $start_time < /dev/null "">&!"" $SEC_SIDE/RCVR_${start_time}.out"
echo "GTM_TEST_DEBUGINFO: "`date`

# Wait for at least 1 transaction to be sent across, to ensure connection is established. Then sleep for the desired time
$gtm_tst/com/wait_until_src_backlog_below.csh $lim_backlog 300
if ($status != 0) then
	# If this error is printed, the subtest anyways will fail. No point in continuing the test.
	echo "TEST-E-TIMEOUT, it took too long to send data at least one update after restarting rcvr. Will exit the test"
	$gtm_tst/com/dbcheck.csh
	exit
endif

echo "#After $test_resync_flush_sleep_time seconds of catchup, the resync seqno from disk should be less than or equal to the info from shm."
echo "###########"
@ sleepfor = $test_resync_flush_sleep_time
while (0 < $sleepfor)
	set disk_resync3 = `$gtm_tst/$tst/u_inref/get_resync_seqno.csh DISK`
	set shm_resync3 = `$gtm_tst/$tst/u_inref/get_resync_seqno.csh SHM`
	set shm_resync3_slt = `$gtm_tst/$tst/u_inref/get_resync_seqno.csh SHM SLT`
	sleep 1
	@ sleepfor--
	if (($disk_resync3 <= $shm_resync3) && ($disk_resync2 < $disk_resync3)) then
		@ sleepfor = 0
	endif
end
# The disk value should be taken "before" noting down the shm. This is to avoid a timing window where,
# shm is noted at time t1 and is x1
# flush happens
# disk resync seqno is noted at time t2 and is x2 (>x1), as the disk flush happened in between.
echo "GTM_TEST_DEBUGINFO: "`date`

echo "#shm_resync3 is: 	GTM_TEST_DEBUGINFO: $shm_resync3"
echo "#disk_resync3 is:	GTM_TEST_DEBUGINFO: $disk_resync3"
echo "#shm_resync3_slt is: 	GTM_TEST_DEBUGINFO: $shm_resync3_slt"

if ($disk_resync3 > $shm_resync3) then
   echo "TEST-E-NOFLUSH, the resync seqno from disk should be less than or equal to the info from shm ."
   echo "disk_resync3: $disk_resync3"
   echo "shm_resync3: $shm_resync3"
endif

echo "#After $test_resync_flush_sleep_time seconds of clearing the backlog, the resync seqno from disk should get updated."
echo "###########"
if ($disk_resync2 >= $disk_resync3) then
	# i.e. they are equal, but not all has been flushed
	echo "TEST-E-NOFLUSH, the resync seqno from disk should have been updated."
	echo "disk_resync2: $disk_resync2"
	echo "disk_resync3: $disk_resync3"
endif

echo "#######################################################################################"
#wait until the backlog is cleared.
echo "#wait until the backlog is cleared."
echo "###########"
echo "GTM_TEST_DEBUGINFO: "`date`
# When ASYNCIO is enabled, when there are filesystem differences between the source and receiver sides of replication
# (particularly f2fs -> xfs OR f2fs -> ext4), we have seen the below call take 35 minutes to finish which is more than
# the default timeout of 1,800 seconds (30 minutes). Therefore pass a 1 hour timeout to the below call.
if (0 != $gtm_test_asyncio) then
	set timeout = 3600
else
	set timeout = ""	# Not asyncio, use the default timeout in the script so pass "" as the timeout
endif
$gtm_tst/com/wait_until_src_backlog_below.csh 0 $timeout
if ($status != 0) then
	echo "#TEST-E-TIMEOUT, it took too long to clear the backlog."
endif

echo "#######################################################################################"
echo "GTM_TEST_DEBUGINFO: "`date`
echo "#After backlog is cleared (and a sleep of 60) all locations (disk, shm SRC slot, shm SLT info) should have the same value"
echo "###########"

@ sleepfor = 60
while (0 < $sleepfor)
	set shm_resync4 = `$gtm_tst/$tst/u_inref/get_resync_seqno.csh SHM`
	set shm_resync4_slt = `$gtm_tst/$tst/u_inref/get_resync_seqno.csh SHM SLT`
	set disk_resync4 = `$gtm_tst/$tst/u_inref/get_resync_seqno.csh DISK`
	sleep 1
	@ sleepfor--
	if (($shm_resync4 == $disk_resync4 ) && ($shm_resync4 == $shm_resync4_slt)) then
		@ sleepfor = 0
	endif
end
echo "GTM_TEST_DEBUGINFO: "`date`

echo "#shm_resync4 is: 	GTM_TEST_DEBUGINFO: $shm_resync4"
echo "#disk_resync4 is: 	GTM_TEST_DEBUGINFO: $disk_resync4"
echo "#shm_resync4_slt is: 	GTM_TEST_DEBUGINFO: $shm_resync4_slt"

if (($shm_resync4 != $disk_resync4 ) || ($shm_resync4 != $shm_resync4_slt)) then
	echo "TEST-E-NOFLUSH,"
	echo "shm_resync4: $shm_resync4"
	echo "disk_resync4: $disk_resync4"
	echo "shm_resync4_slt: $shm_resync4_slt"
endif

# The source server sometimes takes longer than 3 1/2 minutes to shutdown and causes the test to fail.
# do dse buffer_flush before invoking shutdown, to avoid this failure
$gtm_tst/com/dse_buffer_flush.csh
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; $gtm_tst/com/dse_buffer_flush.csh"
$gtm_tst/com/dbcheck.csh
