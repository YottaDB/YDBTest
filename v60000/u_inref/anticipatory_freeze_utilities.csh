#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Specific errors are already triggered in this test. We don't want ENOSPC error to interfere with
# the particular error we expect to happen.
unsetenv gtm_test_freeze_on_error
unsetenv gtm_test_fake_enospc
# When journal file writes get blocked by the freeze, the source server waits for writes while holding the
# source server latch. This prevents an online rollback, which trys to grab the latch in mur_open_files.
setenv gtm_test_jnlfileonly 0
unsetenv gtm_test_jnlpool_sync

# Helper aliases
alias setfreeze				'$MUPIP replic -source -freeze=on -comment=\!:1'
alias unfreeze				'$MUPIP replic -source -freeze=off'
alias onerror_clnup_n_exit		'if ($status) goto error'
alias wait_for_log			'$gtm_tst/com/wait_for_log.csh -message \!:1 -log \!:2 -duration 120; onerror_clnup_n_exit'
alias wait_for_proc_to_die		'$gtm_tst/com/wait_for_proc_to_die.csh \!:1 120 ; onerror_clnup_n_exit'
alias check_error_exist			'$gtm_tst/com/check_error_exist.csh \!:1 \!:2*'
alias update_and_suicide		'$gtm_exe/mumps -run suicide^antifreezeutil >>&! suicide.out'

setenv gtm_test_disable_randomdbtn			# To allow MUPIP DOWNGRADE
setenv gtm_test_mupip_set_version 	"disable"	# To allow MUPIP JOURNAL -ONLINE -ROLLBACK
setenv test_encryption			"NON_ENCRYPT"	# Disable encryption due to MUPIP DOWNGRADE below
setenv gtm_custom_errors		"/dev/null"
setenv gtm_test_online_integ		"-noonline"	# To avoid SSV4NOALLOW due to downgrade/rollback

# Each of the utilities below is invoked AFTER a GT.M process does an update and gets kill -9ed. Since the Kill -9 can reach the
# GT.M process when it is in the middle of a wcs_wtstart, subsequent wcs_flu should handle it gracefully by invoking wcs_recover
# and completing the pending writes. Set the below white box test case to avoid any asserts in wcs_flu.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29

source $gtm_tst/com/gtm_test_setbeforeimage.csh		# We need BEFORE IMAGE journaling for ROLLBACK (done below)

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 2 125 1000 1024 4096 1024 4096

$MSR START INST1 INST2

# The purpose of the test is to exercise MUINSTFROZEN/MUINSTUNFROZEN code path for each utility that can open journal pool. But,
# some utilities are not database intensive (like MUPIP EXTRACT). But, even these utilities invoke wcs_flu to flush any dirty
# buffers and to keep buffers dirty as much as possible in the shared memory, keep the flush interval to a large enough value.
$MSR RUN INST1 '$MUPIP set -flush=00:10:00 -reg "*"'	# Flush buffers once in 10 minutes.

# Note: Most of the below operations on all the regions. But, since it is not guaranteed that inode of a.dat is always less than
# the inode of mumps.dat, we cannot be sure as to which region will encounter the instance freeze first. So, while looking for
# MUINSTFROZEN/MUINSTUNFROZEN messages, don't bother about the actual file name being printed (the 'awk' expression is meant for
# that purpose).

echo ""
echo "# MUPIP INTEG -REG"
update_and_suicide
setfreeze MUPIP_INTEG
($MUPIP integ -reg "*" >&! integ.out & ; echo $! >! integ.pid)	>>&! bkgrnd_pids.list
wait_for_log "MUINSTFROZEN" integ.out
unfreeze
wait_for_log "MUINSTUNFROZEN" integ.out
check_error_exist integ.out "MUINSTFROZEN" "MUINSTUNFROZEN"
wait_for_proc_to_die `cat integ.pid`

echo ""
echo "# MUPIP BACKUP"
update_and_suicide
setfreeze MUPIP_BACKUP
\mkdir bak
($MUPIP backup -replinstance=./bak/mumps.repl "*" ./bak >&! backup.out & ; echo $! >! backup.pid) >>&! bkgrnd_pids.list
wait_for_log "MUINSTFROZEN" backup.out
unfreeze
wait_for_log "MUINSTUNFROZEN" backup.out
check_error_exist backup.out "MUINSTFROZEN" "MUINSTUNFROZEN"
wait_for_proc_to_die `cat backup.pid`

echo ""
echo "# MUPIP FREEZE"
update_and_suicide
setfreeze MUPIP_FREEZE
($MUPIP freeze -on "*" >&! freeze.out & ; echo $! >! freeze.pid) >>&! bkgrnd_pids.list
wait_for_log "MUINSTFROZEN" freeze.out
unfreeze
wait_for_log "MUINSTUNFROZEN" freeze.out
check_error_exist freeze.out "MUINSTFROZEN" "MUINSTUNFROZEN"
# Unfreeze the region FREEZE itself for things to proceed for the purpose of the test.
$MUPIP freeze -off "*" >&! unfreeze.out
wait_for_proc_to_die `cat freeze.pid`

echo ""
echo "# MUPIP SET -JOURNAL"
update_and_suicide
setfreeze MUPIP_SET_JOURNAL
($MUPIP set -journal=enable,on,before -reg "*" >&! mupip_set1.out & ; echo $! >! mupip_set1.pid) >>&! bkgrnd_pids.list
wait_for_log "MUINSTFROZEN" mupip_set1.out
unfreeze
wait_for_log "MUINSTUNFROZEN" mupip_set1.out
check_error_exist mupip_set1.out "MUINSTFROZEN" "MUINSTUNFROZEN"
wait_for_proc_to_die `cat mupip_set1.pid`

echo ""
echo "# MUPIP SET -EXTENSION"
update_and_suicide
setfreeze MUPIP_SET_EXTENSION
($MUPIP set -extension=1000 -reg "*" >&! mupip_set2.out & ; echo $! >! mupip_set2.pid) >>&! bkgrnd_pids.list
wait_for_log "MUINSTFROZEN" mupip_set2.out
unfreeze
wait_for_log "MUINSTUNFROZEN" mupip_set2.out
check_error_exist mupip_set2.out "MUINSTFROZEN" "MUINSTUNFROZEN"
wait_for_proc_to_die `cat mupip_set2.pid`

echo ""
echo "# MUPIP EXTRACT -FREEZE"
update_and_suicide
setfreeze MUPIP_EXTRACT_FREEZE
($MUPIP extract -freeze allreg.ext >&! extract.out & ; echo $! >! extract.pid) >>&! bkgrnd_pids.list
wait_for_log "MUINSTFROZEN" extract.out
unfreeze
wait_for_log "MUINSTUNFROZEN" extract.out
check_error_exist extract.out "MUINSTFROZEN" "MUINSTUNFROZEN"
wait_for_proc_to_die `cat extract.pid`

echo ""
echo "# MUPIP EXTEND"
update_and_suicide
setfreeze MUPIP_EXTEND_FREEZE
($MUPIP extend -blocks=100 DEFAULT >&! extend.out & ; echo $! >! extend.pid) >>&! bkgrnd_pids.list
wait_for_log "MUINSTFROZEN" extend.out
unfreeze
wait_for_log "MUINSTUNFROZEN" extend.out
check_error_exist extend.out "MUINSTFROZEN" "MUINSTUNFROZEN"
wait_for_proc_to_die `cat extend.pid`

echo ""
echo "# MUPIP REORG"
$gtm_exe/mumps -run %XCMD 'do updates4reorg^antifreezeutil'
update_and_suicide
setfreeze MUPIP_REORG
($MUPIP reorg >&! reorg.out & ; echo $! >! reorg.pid) >>&! bkgrnd_pids.list
wait_for_log "MUINSTFROZEN" reorg.out
unfreeze
wait_for_log "MUINSTUNFROZEN" reorg.out
check_error_exist reorg.out "MUINSTFROZEN" "MUINSTUNFROZEN"
wait_for_proc_to_die `cat reorg.pid`

echo ""
echo "# MUPIP REORG -DOWNGRADE"
update_and_suicide
setfreeze MUPIP_DOWNGRADE
($MUPIP reorg -downgrade -reg "*" >&! downgrade.out & ; echo $! >! downgrade.pid) >>&! bkgrnd_pids.list
wait_for_log "MUINSTFROZEN" downgrade.out
unfreeze
wait_for_log "MUINSTUNFROZEN" downgrade.out
check_error_exist downgrade.out "MUINSTFROZEN" "MUINSTUNFROZEN"
wait_for_proc_to_die `cat downgrade.pid`

echo ""
echo "# MUPIP REORG -UPGRADE"
update_and_suicide
setfreeze MUPIP_UPGRADE
($MUPIP reorg -upgrade -reg "*" >&! upgrade.out & ; echo $! >! upgrade.pid) >>&! bkgrnd_pids.list
wait_for_log "MUINSTFROZEN" upgrade.out
unfreeze
wait_for_log "MUINSTUNFROZEN" upgrade.out
check_error_exist upgrade.out "MUINSTFROZEN" "MUINSTUNFROZEN"
wait_for_proc_to_die `cat upgrade.pid`

echo ""
echo "# MUPIP JOURNAL -ONLINE -ROLLBACK"
update_and_suicide
setfreeze MUPIP_JOURNAL_ONLINE_ROLLBACK
$gtm_tst/com/backup_dbjnl.csh b4_online_rlbk '*.dat *.repl *.gld *.mjl*'	# To aid in debugging
# Below backward rollback invocation is expected to issue MUINSTFROZEN message and the test driver reacts to it etc.
# Therefore pass "-backward" explicitly to mupip_rollback.csh (and avoid implicit "-forward" rollback invocation that
# would otherwise happen by default) as that otherwise disturbs the test flow.
($gtm_tst/com/mupip_rollback.csh "" -backward -online -verbose "*" >&! online_rlbk.out & ; echo $! >! online_rlbk.pid)	\
												>>&! bkgrnd_pids.list
wait_for_log "MUINSTFROZEN" online_rlbk.out
unfreeze
wait_for_log "MUINSTUNFROZEN" online_rlbk.out
check_error_exist online_rlbk.out "MUINSTFROZEN" "MUINSTUNFROZEN"
wait_for_proc_to_die `cat online_rlbk.pid`

echo ""
echo "# To test Regular Rollback, we need the Shared Memory and Journal Pool around, but not the processes. So, Kill -9 them"
echo "---> Kill the GT.M process"
update_and_suicide
echo "---> SYNC and Kill the Source Server"
source $gtm_tst/$tst/u_inref/kill_src_srv.csh	# Source the script so that aliases are inherited

echo ""
echo "# MUPIP JOURNAL -ROLLBACK"
setfreeze MUPIP_JOURNAL_ROLLBACK
$gtm_tst/com/backup_dbjnl.csh b4_regular_rlbk '*.dat *.repl *.gld *.mjl*'	# To aid in debugging
# Below backward rollback invocation is expected to issue MUINSTFROZEN message and the test driver reacts to it etc.
# Therefore pass "-backward" explicitly to mupip_rollback.csh (and avoid implicit "-forward" rollback invocation that
# would otherwise happen by default) as that otherwise disturbs the test flow.
($gtm_tst/com/mupip_rollback.csh -backward -verbose "*" >&! rlbk.out & ; echo $! >! rlbk.pid) >>&! bkgrnd_pids.list
wait_for_log "MUINSTFROZEN" rlbk.out
unfreeze
wait_for_log "MUINSTUNFROZEN" rlbk.out
check_error_exist rlbk.out "MUINSTFROZEN" "MUINSTUNFROZEN"
wait_for_proc_to_die `cat rlbk.pid`

echo ""
echo "# At this point, the Source Server is dead and the Shared Memory is removed as well. So, go ahead and start a new one."
$MSR STARTSRC INST1 INST2

echo ""
echo "# MUPIP RUNDOWN -REG DEFAULT"
echo "---> Do one update on DEFAULT and suicide"
($gtm_exe/mumps -run default^antifreezeutil) >&! DEFAULT_update.out
echo "---> Start a background process which does one update on AREG and hangs until told otherwise or Kill -9ed"
($gtm_exe/mumps -run updatehang^antifreezeutil >&! AREG_update.out &; echo $! >! AREG_update.pid) >>&! bkgrnd_pids.list
# Wait for the ^a=1 update to have been written to the Journal Pool. Use "PID=xxxx" string to be printed in AREG_update.out
wait_for_log "PID=" AREG_update.out
echo "---> SYNC and Kill the Source Server"
source $gtm_tst/$tst/u_inref/kill_src_srv.csh	# Source the script so that aliases are inherited
setfreeze MUPIP_RUNDOWN_REG
######################################
# Pre-Rundown DEBUG information
######################################
$MUPIP ftok mumps.dat	>&! DEFAULT_ftok1.before
$MUPIP ftok a.dat	>&! AREG_ftok1.before
$ps 			>&! pslist1.before
$gtm_tst/com/ipcs	>&! ipcs1.before
######################################
# End DEBUG information
######################################
# At this point, the instance is frozen, DEFAULT region's Shared Memory along with the Journal Pool is leftover. But, AREG shared
# memory is being actively used. A RUNDOWN -REG DEFAULT,AREG should fail to RUNDOWN ARsEG (for obvious reasons). But, it should also
# hang while running down DEFAULT region because the instance is frozen. Once the freeze is lifted, DEFAULT region's rundown will
# be successful.
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl1.outx
($MUPIP rundown -reg AREG,DEFAULT -override >&! rundown_reg.out & ; echo $! >! rundown_reg.pid) >>&! bkgrnd_pids.list
######################################
# Post-Rundown DEBUG information
######################################
$MUPIP ftok mumps.dat	>&! DEFAULT_ftok1.after
$MUPIP ftok a.dat	>&! AREG_ftok1.after
$ps 			>&! pslist1.after
$gtm_tst/com/ipcs	>&! ipcs1.after
######################################
# End DEBUG information
######################################
wait_for_log "MUINSTFROZEN" rundown_reg.out
unfreeze
wait_for_log "MUINSTUNFROZEN" rundown_reg.out
wait_for_proc_to_die `cat rundown_reg.pid`
check_error_exist rundown_reg.out "MUINSTFROZEN" "MUINSTUNFROZEN" "MUNOTALLSEC" "MUFILRNDWNSUC"

# At this point, we have the DEFAULT region's Shared Memory successfully rundown. But, one process is attached to the AREG and
# the Journal Pool. Kill this process and attempt a RUNDOWN -REG "*". This way, we test both RUNDOWN -REG "*" as well as the
# Freeze aspect of it. This should rundown both AREG as well as the Journal Pool.
echo ""
echo "# MUPIP RUNDOWN -REG '*'"
# To test, RUNDOWN -REG "*", kill the background process to leave AREG's Shared Memory.
echo "---> Kill the process attached to AREG and Journal Pool"
set AREG_pid = `cat AREG_update.pid`
$kill9 $AREG_pid

# Journal pool is not yet removed. So, go ahead and setup the instance freeze
touch set_freeze_output.outx # tee doesn't create unless there's output
setfreeze MUPIP_RUNDOWN_REG_STAR |& tee set_freeze_output.outx |& $grep -v NOJNLPOOL
# Skip the below part if a current argumentless rundown removed the journal pool
if ("" == `$grep NOJNLPOOL set_freeze_output.outx`) then
	######################################
	# Pre-Rundown_Star DEBUG information
	######################################
	$MUPIP ftok mumps.dat	>&! DEFAULT_ftok2.before
	$MUPIP ftok a.dat	>&! AREG_ftok2.before
	$ps 			>&! pslist2.before1
	$gtm_tst/com/ipcs	>&! ipcs2.before1
	######################################
	# End DEBUG information
	######################################
	$MUPIP rundown -relinkctl >&! mupip_rundown_rctl2.outx
	($MUPIP rundown -reg "*" -override >&! rundown_reg_star.outx & ; echo $! >! rundown_reg_star.pid) >>&! bkgrnd_pids.list
	######################################
	# Post-Rundown_Star DEBUG information
	######################################
	$MUPIP ftok mumps.dat	>&! DEFAULT_ftok2.after
	$MUPIP ftok a.dat	>&! AREG_ftok2.after
	$ps 			>&! pslist2.after
	$gtm_tst/com/ipcs	>&! ipcs2.after
	######################################
	# End DEBUG information
	######################################
	wait_for_log "MUINSTFROZEN" rundown_reg_star.outx
	unfreeze
	wait_for_log "MUINSTUNFROZEN" rundown_reg_star.outx
	wait_for_proc_to_die `cat rundown_reg_star.pid`
	# Occasionally, the RUNDOWN done above catches the UNFREEZE command hanging onto the journal pool causing MUJPOOLRNDWNFL messages.
	# To avoid that, do another rundown to make sure it is successful. But, before that, grep out the MUJPOOLRNDWNFL messages.
	sort -u rundown_reg_star.outx | $grep -v MUJPOOLRNDWNFL >&! rundown_reg_star_sorted.out
	echo "------ EXPECTED ERRORS FROM MUPIP RUNDOWN ------" >>&! REPLINSTFROZEN_occurrence.outx
	check_error_exist rundown_reg_star_sorted.out "MUINSTFROZEN" "MUINSTUNFROZEN" "MUFILRNDWNSUC" "MUJPOOLRNDWNSUC"	>>&! REPLINSTFROZEN_occurrence.outx
	if ($status) then
		cat REPLINSTFROZEN_occurrence.outx
		onerror_clnup_n_exit
	endif
	$MUPIP rundown -reg "*" -override >&! rundown_reg_star_attempt2.out
endif

$MUPIP rundown -relinkctl >&! mupip_rundown_rctl3.outx

# Filter out any REPLINSTFROZEN messages in the Source Server log. Since the count of these messages in the Source Server log
# is not deterministic, don't bother including them in the reference file.
echo "------ REPLINSTFROZEN ERRORS FROM SOURCE LOGS ------" >>&! REPLINSTFROZEN_occurrence.outx
$grep REPLINSTFROZEN SRC_*.log >>&! REPLINSTFROZEN_occurrence.outx
if (! $status) then
	foreach file (SRC_*.log)
		check_error_exist $file REPLINSTFROZEN >>&! REPLINSTFROZEN_discarded.outx
	end
endif

# Since the Source Server is already dead by now, invoke dbcheck.csh with -noshut. But, since -noshut will NOT shut the Receiver
# Server as well, do explict shutdown of the Receiver and Passive Source Server.
# Also refreshlinks to reflect the fact that SRC of INST1->INST2 is no longer alive
$MSR REFRESHLINK INST1 INST2
$MSR STOPRCV INST1 INST2

$gtm_tst/com/dbcheck.csh -noshut

exit 0

error:
	$MSR STOP INST1 INST2				# Stop any running replication servers
	$ps >&! pslist_on_error.outx
	set last_bkgrnd_pid = `$tail -n 1 bkgrnd_pids.list`
	$kill -15 $last_bkgrnd_pid			# Kill the last backgrounded activity
	# Also kill the mumps process - updatehang^antifreezeutil - if it is still alive.
	if (-f AREG_update.pid) $kill9 `cat AREG_update.pid`
	exit -1
