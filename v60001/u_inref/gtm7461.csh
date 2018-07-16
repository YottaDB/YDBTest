#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
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

echo "# start subtest"

# Do not randomly freeze
unsetenv gtm_test_freeze_on_error
unsetenv gtm_test_fake_enospc

setenv gtm_test_mupip_set_version "disable"                     # Getting some odd effects from V4 upgrade, so disable

echo "# create database"

unsetenv gtm_repl_instance gtm_custom_errors
$gtm_tst/com/dbcreate.csh mumps 4 125 1000 4096 2000 4096 2000 >&! dbcreate.out

echo "# config database"

unsetenv gtm_repl_instance
$MUPIP set -region "*" -replic=on >&! journalcfg.out
$MUPIP set -region "*" -inst_freeze_on_error >&! instfreezecfg.out

setenv gtm_custom_errors $cwd/custom_errors.txt
echo JNLFILEOPNERR >! ${gtm_custom_errors}

echo "# start passive source server"

setenv gtm_repl_instance "mumps.repl"
source $gtm_tst/com/passive_start_upd_enable.csh >&! startsrc.out

echo "# start imptp"

setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh 4 >&! imptp_${gtm_test_jobid}.out

echo "# wait for log rollover"

$gtm_tst/com/wait_for_n_jnl.csh -lognum 5 -duration 3600 -poll 5

echo "# stop passive source server"

$MUPIP replicate -source -shutdown -timeout=0 >&! replicstop.out
$gtm_tst/com/wait_for_log.csh -log SRC_*.log -message "Source server exiting"

echo "# stop imptp"

$gtm_tst/com/endtp.csh >&! endtp_${gtm_test_jobid}.out

source $gtm_tst/com/can_ipcs_be_leftover.csh
if ($status) then
	# Rundown the databases that are left over but not the journal pool as that is needed to trigger REPLINSTFROZEN.
	# So temporarily unsetenv gtm_repl_instance
	set save_gtm_repl_instance = $gtm_repl_instance
	unsetenv gtm_repl_instance
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown before moving jnl files over
	setenv gtm_repl_instance $save_gtm_repl_instance
endif
echo "# remove journal files"

$gtm_tst/com/backup_dbjnl.csh "" "*.mjl*" "mv"

echo "# start MUPIP JOURNAL -ROLLBACK -BACKWARD which should trigger instance freeze"

set syslog_before1 = `date +"%b %e %H:%M:%S"`
echo "$syslog_before1" > syslog_before1.txt

sleep 1		# Managed to slip out of the getoper window somehow, so give it a second to be safe.

# do not use mupip_rollback.csh since we want to know the rollback pid which is not possible if we use a wrapper script
($MUPIP journal -rollback -backward -resync=10000 '*' >& rollback.outx & ; echo $! > rollback_pid.txt) >& /dev/null

set rollbackpid = `cat rollback_pid.txt`
$gtm_tst/com/wait_for_proc_to_die.csh $rollbackpid

echo "# check syslog to confirm instance freeze related messages (REPLINSTFROZEN/JNLFILEOPNERR) are seen"
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt
$grep -E "REPLINSTFROZEN|JNLFILEOPNERR" syslog1.txt | sed 's/.*%YDB/%YDB/;s/ -- .*//' | sed 's/'$rollbackpid'/xxxx/'

echo "# unfreeze and wait"
$MUPIP replic -source -freeze=off >&! freeze_off.outx

# YDB-E-NOJNLPOOL can occur if an argumentless rundown is done by some other test in this timeframe
$grep -v 'YDB-E-NOJNLPOOL' freeze_off.outx

echo "# final rundown"

$MUPIP rundown -region '*' >&! rundown.out

# We are trashing things pretty well, so don't bother with a dbcheck

echo "# done"

exit
