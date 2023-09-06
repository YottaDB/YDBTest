#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# has one optional argument: sync_to_disk
# which specifies whether sync_to_disk will be called or not
# which is necessary if the link will be crashed right after the sync.
#
# The tool first waits for the souce server backlog to clear
#   - by calling wait_until_src_backlog_below.csh 0
#   - If there is no backlog progress for $change_check_frequency seconds, exits if update process too did not show progress
# Then the tool waits for the receiver server backlog to clear
#   - by calling wait_until_rcvr_backlog_below.csh 0
# Finally flush the shared memory to disk if asked for

if ( ("MULTISITE" == $test_replic) && !($?inside_multisite_replic) ) then
	echo "RFSYNC-E-MSR For multisite actions pls. use MSR SYNC ALL LINKS, and not a plain Rf_sync.csh call"
	echo "Instances will not be synced"
	exit 1
endif
set format="%Y %m %d %H %M %S %Z"
set dispformat = "%H:%M:%S"
set logfile = "rf_sync_`date +%H%M%S`_$$.out"
echo "Started at `date +$dispformat`" >>&! $logfile
if ($?gtm_tst_rfsync_check_frequency) then
	@ change_check_frequency = $gtm_tst_rfsync_check_frequency
else
	@ change_check_frequency = 120
endif
set nowtime = `date +%s`
set starttime = "$nowtime"
# Previously we had a timeout of 3 hours (the now-nixed $test_timeout env var) here but that was not enough on slow ARMV6L boxes.
# So bump the timeout to a much higher value (12 hours = 43,200 seconds)
# Note that as long as this timeout is higher than $gtm_test_hang_alert_sec, this timeout is effectively infinite
# since before this timeout occurs, we would see a TEST-E-HANG/TEST-E-TIMEDOUT email from the test framework.
@ timeout = $nowtime + 43200

if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
	# reset gtm_test_instsecondary back to null if we see the current GT.M version used is pre multisite_replic
	# keep the single-double quote below.pri_getenv needs to be expanded here whereas gtm_exe should only be on the remote
        setenv ver_chk `$pri_shell "$pri_getenv;"'echo $gtm_exe:h:t'|$tail -n 1`
	if ( ("V4" == `echo $ver_chk|cut -c1-2`) || ("V50000" == `echo $ver_chk|cut -c1-6`) ) setenv gtm_test_instsecondary
endif

# first check if the source server is in active mode and transactions are getting replicated
set check_act_log = "${logfile:r}_check_src_active.out"
set src_act = `$pri_shell "$pri_getenv; cd $PRI_SIDE;"'$MUPIP replicate -source '$gtm_test_instsecondary' -showbacklog >& '$check_act_log' ; $grep -c "Source Server is in passive mode" '$check_act_log''`
if ($src_act) then
	echo "RFSYNC-I-PASSIVEMODE. Source server not replicating at this point in time.Cannot Sync this link."
	echo "Source server to $gtm_test_instsecondary is running in PASSIVE mode. Cannot sync this link. Check $PRI_SIDE/$check_act_log"	>>&! $logfile
	exit
endif
# Get last transaction processed by update process
set prev_updtn = `$sec_shell "$sec_getenv; cd $SEC_SIDE;$gtm_tst/com/get_rcvr_backlog.csh updproc"`
if ("" == "$prev_updtn") then
	echo "RFSYNC-E-UPDPROC unable to get last transaction processed by update process"	>>&! $logfile
	echo "Check get_rcvr_backlog logs"							>>&! $logfile
	exit 1
endif
set updtn = "$prev_updtn"

# Get current source backlog
set prev_pribacklog = `$pri_shell "$pri_getenv;cd $PRI_SIDE;$gtm_tst/com/get_src_backlog.csh $gtm_test_cur_sec_name"`
if ("" == "$prev_pribacklog") then
	echo "RFSYNC-E-SRCBACKLOG unable to get current source server backlog"			>>&! $logfile
	echo "Check get_src_backlog logs"							>>&! $logfile
	exit 1
endif
set pribacklog = "$prev_pribacklog"

if ($?gtm_test_fake_enospc) then
	if ($gtm_test_fake_enospc == 1) then
		# If processes exited while the instance was frozen, there may be unflushed journal records left in the buffer.
		# If the source is running with jnlfileonly or doing a catchup from journal files, it won't see these records
		# until someone flushes them, so force a flush.
		# Use DSE instead of MUPIP RUNDOWN because we still have a source server attached, so the later complains.
		$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/dse_buffer_flush.csh"
	endif
endif

# Wait for source server backlog to clear
set logfile_src = "${logfile:r}_src.out"
while ($nowtime <= $timeout)
	set nowtime = `date +%s`
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/wait_until_src_backlog_below.csh 0 $change_check_frequency $logfile_src noerror"
	if ( "$tst_now_primary:r:r:r:r" != "$HOST:r:r:r:r" ) then
		$rcp "$tst_now_primary":"$PRI_SIDE/$logfile_src" .
		set filepath = "."
	else
		set filepath = "$PRI_SIDE"
	endif
	if ( 0 != `$grep -c ".-E-." $filepath/$logfile_src`) then
		echo "RFSYNC-E-FAIL wait_until_src_backlog_below.csh failed with the below"	>>&! $logfile
		cat $filepath/$logfile_src							>>&! $logfile
		exit 1
	endif
	# Showbacklog of primary
	set prev_pribacklog = "$pribacklog"
	set pribacklog = `$gtm_tst/com/compute_src_backlog_from_showbacklog_file.csh $filepath/$logfile_src`
	set srcsno  = `$tst_awk '/Last transaction sequence number posted/ {print $NF}' $filepath/$logfile_src | tail -1`
	if ($status) then
		echo $backlog 									>>&! $logfile
		echo "RFSYNC-E-SRCBACKLOG unable to get source backlog from $logfile_src"	>>&! $logfile
		cat $filepath/$logfile_src							>>&! $logfile
		exit 1
	endif
	if ( $pribacklog == "0" ) break

	if ( $prev_pribacklog == $pribacklog) then
		# Now that we have done at least one invocation of wait_until_src_backlog_below.csh above
		# and failed to clear the source side backlog (i.e. it is a test hang situation), check if
		# caller subtest script wants us to do special stuff.
		if ($?ydb_test_rf_sync_run_instance_unfreeze) then
			if ($ydb_test_rf_sync_run_instance_unfreeze) then
				# This is a signal from the v62000/gtm8086 subtest that it is a test hang situation
				# that needs a manual instance unfreeze to clear the hang. So do that and retry the RF_sync loop.
				echo "date : `date`" >>& inst_unfreeze.out
				# First check if the instance is frozen. Do the unfreeze only if it is frozen.
				set isfrozen = `$MUPIP replic -source -checkhealth |& $grep -c "Warning: Instance Freeze is ON"`
				if (1 == $isfrozen) then
					echo "Found instance freeze to be ON. Proceeding with instance unfreeze." >>& inst_unfreeze.out
					$MUPIP replic -source -freeze=off >>& inst_unfreeze.out
					# Now that we have cleared the instance freeze, do not descend into following code
					# which will print a RFSYNC-E-NOPROGRESS thereby causing an unnecessary test failure.
					# Instead retry the wait for backlog to clear.
					continue
				else
					echo "Found instance freeze to be OFF. Not doing instance unfreeze." >>& inst_unfreeze.out
				endif
			endif
		endif
		# Take stack trace of receiver server for debugging
		$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/get_rcvr_stack_trace.csh ${logfile:r}"
		# Check if the update process has some progress
		set prev_updtn = "$updtn"
		set updtn = `$sec_shell "$sec_getenv; cd $SEC_SIDE;$gtm_tst/com/get_rcvr_backlog.csh updproc"`
		if ($updtn == $prev_updtn) then
			# Update process did not progress. Record that fact but continue waiting until timeout.
			echo "RFSYNC-E-NOPROGRESS : pribacklog = $pribacklog ; updtn = $updtn for $change_check_frequency seconds : `date +$dispformat`"
		endif
	endif
end
if ($nowtime > $timeout) then
	# timed out
	echo "RFSYNC-E-TIMEOUT source backlog wait timed out : `date +$dispformat`"
	echo "RFSYNC-E-TIMEOUT source backlog wait timed out : `date +$dispformat`"		>>&! $logfile
	goto timeout
endif
echo "Source backlog becomes 0 at: `date +$dispformat`" >>&! $logfile

# Wait until receiver gets everything sent by primary
set logfile_rcvr = "${logfile:r}_rcvr.out"
while ($nowtime <= $timeout)
	set nowtime = `date +%s`
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_until_rcvr_backlog_below.csh 0 $change_check_frequency $logfile_rcvr noerror"
	# Showbacklog of secondary
	if ( "$tst_now_secondary:r:r:r:r" != "$HOST:r:r:r:r" ) then
		$rcp "$tst_now_secondary":"$SEC_SIDE/$logfile_rcvr" .
		set filepath = "."
	else
		set filepath = "$SEC_SIDE"
	endif
	if ( 0 != `$grep -c ".-E-." $filepath/$logfile_rcvr`) then
		echo "RFSYNC-E-FAIL wait_until_rcvr_backlog_below.csh failed with the below"	>>&! $logfile
		cat $filepath/$logfile_rcvr							>>&! $logfile
		exit 1
	endif
	set rblog = `$tst_awk '/number of backlog/ {print $1}' $filepath/$logfile_rcvr`
	set rcvrsno = `$tst_awk '/written to receive pool/ {print $1}' $filepath/$logfile_rcvr`
	if ( ("" == "$rblog") || ("" == "$rcvrsno") ) then
		echo "RFSYNC-E-RCVRBACKLOG unable to get rcvr backlog from $logfile_rcvr"	>>&! $logfile
		cat $filepath/$logfile_rcvr							>>&! $logfile
		exit 1
	endif
	# receiver should get same sequence number and then backlog should be zero
	if ( $rcvrsno == $srcsno && $rblog == "0") then
		break
	endif
	# This if is for an unusual case
	if ($rcvrsno > $srcsno) then
		# This is not normally possible. Throw error
		echo "RFSYNC-E-SEQNO receiver seqno $rcvrsno is greater than source seqno $srcsno"	>>&! $logfile
		exit 1
	endif
end

if ($nowtime > $timeout) then
	# timed out
	echo "RFSYNC-E-TIMEOUT receiver backlog wait timed out at : `date +$dispformat`"
	echo "RFSYNC-E-TIMEOUT receiver backlog wait timed out at : `date +$dispformat`"		>>&! $logfile
	goto timeout
endif
echo "Receiver backlog becomes 0 at: `date +$dispformat`" >>&! $logfile

if ("$1" == "sync_to_disk") then
	# Now wait for the shared memory to flush to disk. Once GTM-5337 is fixed, remove "view FLUSH" command in the below two lines.
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/sync_to_disk.csh 0"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/sync_to_disk.csh 0"
endif

set nowtime = `date +%s`
@ difftime = $nowtime - $starttime
echo "Ends at : `date +$dispformat`"		>>&! $logfile
echo "Total wait was $difftime seconds."	>>&! $logfile

goto end

timeout:
	set psdebug = "${ps:s/ps /ps -l /}"  #BYPASSOK ps
	set psout = "${logfile:r}_timeout_pslist.outx"
	set nsout = "${logfile:r}_timeout_ss.outx"
	set stackbase = "${logfile:r}_timeout"
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $psdebug >&! ${psout} ; $ss >&! ${nsout} ; $gtm_tst/com/get_src_stack_trace.csh ${stackbase}"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $psdebug >&! ${psout} ; $ss >&! ${nsout} ; $gtm_tst/com/get_rcvr_stack_trace.csh ${stackbase}"
	exit 1

end:
	true
