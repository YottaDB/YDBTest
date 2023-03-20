#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
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

#################################################################
# The scenario that TIAA ran into is the following.
# 	A->B replication was happening fine.
# 	The source server was reading from jnlpool.
# 	Dayend was running so eventually the backlog increased and source server had to go to the file.
# 	Soon afterwards, the journal file system ran out of space.
# 		And replication got closed (REPLJNLCLOSED) and journaling got turned off in many regions at different
# 		timestamps (separated by a few seconds).
# 		And this caused the source server to not be able to read from the journal files.
# 	They then killed the source server (mumps processes are still running updates).
# 	And shipped a fresh backup of the primary and restored it on the secondary and restarted replication.
# 		This replication started out from the file.
# 		And eventually caught up and switched to the pool.
# 	That is when the source server got the GTMASSERT.
#################################################################
# Note: Relies on IGS MOUNT, so Linux-only.
#################################################################


set jnldir="jnldir"
set num_regions=8

# This test explicitly runs out of journal space, so make sure we can handle it consistently.
unsetenv gtm_custom_errors
setenv gtm_test_jnlfileonly		0
unsetenv gtm_test_jnlpool_sync
setenv gtm_error_on_jnl_file_lost	0
setenv gtm_white_box_test_case_enable	1
setenv gtm_white_box_test_case_number	16	# WBTEST_JNL_FILE_LOST_DSKADDR

setenv acc_meth				"BG"
setenv gtm_test_dbfill			"IMPTP"
setenv gtm_test_jobcnt			2

$MULTISITE_REPLIC_PREPARE 2

echo "# Set up small jnldir"
mkdir -p $jnldir
$gtm_com/IGS MOUNT $jnldir 393216 2048
if ($status) then
	echo "TEST-E-FAIL, Mounting tmpfs failed. Exiting test now."
	exit 1
endif
echo "$gtm_com/IGS UMOUNT `pwd`/$jnldir" >>& ../cleanup.csh

echo "# Create database"
$MSR RUN INST2 mkdir -p $jnldir 											>& mkdir_INST2.log
$gtm_tst/com/dbcreate.csh mumps $num_regions 125 1000 4096 2000 4096 2000 -jnl_auto=16384 -jnl_prefix=${jnldir}/	>& dbcreate.log
$MSR START INST1 INST2 RP												>& first_start.log

get_msrtime
set start_time=$time_msr

echo "# Start updates"
$gtm_tst/com/imptp.csh													>& imptp.log
source $gtm_tst/com/imptp_check_error.csh imptp.log; if ($status) exit 1
# Tell STOPSRC below that we still have processes running
setenv gtm_test_other_bg_processes 1
# We want to run out of space while the receiver is running, and most of the time we do,
# but we run out early too often to ignore, and tuning the test to get it consistent hasn't
# been successful, so start looking for REPLJNLCLOSED from here.
set syslog_before = `$gtm_dist/mumps -run timestampdh -1`
$gtm_tst/com/wait_for_transaction_seqno.csh +5000 SRC 120 INSTANCE2 noerror

echo "# Stop receiver"
$MSR STOPRCV INST1 INST2												>& stoprcv1.log

echo "# Wait to overflow the journal pool significantly"
$gtm_tst/com/wait_for_transaction_seqno.csh +450000 SRC 120 INSTANCE2 noerror

echo "# Restart receiver"
$MSR STARTRCV INST1 INST2												>& startrcv1.log

echo "# Wait until we are out of journal space (REPLJNLCLOSED)"
$gtm_tst/com/getoper.csh "$syslog_before" "" syslog.txt "" REPLJNLCLOSED $num_regions
$gtm_tst/com/wait_for_transaction_seqno.csh +5000 SRC 120 INSTANCE2 noerror

echo "# Shut down replication"
$MSR STOPSRC INST1 INST2												>& stopsrc_shutdown.log
# Handle errors which can show up if the source hits a journal file error
get_msrtime
set stopsrc_time=$time_msr
mv SRC_${start_time}.log SRC_${start_time}.logx
$grep -v REPLBRKNTRANS SRC_${start_time}.logx > SRC_${start_time}.log
$tst_cmpsilent SRC_${start_time}.log SRC_${start_time}.logx || set got_src_error
# To monitor pool/file switches, uncomment the following.
#grep -i reading SRC_${start_time}.logx | mail -s "[${HOST:ar}] [gtm8076] Source Reading Changes" $mailing_list
$MSR STOPRCV INST1 INST2												>& stoprcv_shutdown.log

echo "# Switch from small jnldir to normal jnldir"
mkdir -p ${jnldir}.normal
setenv test_jnldir ${jnldir}.normal

echo "# Enable journaling"
$gtm_tst/com/jnl_on.csh $test_jnldir -replic=on

echo "# Ship database to secondary"
mkdir -p bak1
$MUPIP backup -replinstance=bak1/srcinstback.repl "*" bak1								>& backup.log
$MSR RUN INST2 '$gtm_tst/com/backup_dbjnl.csh "bak_preship" "*.dat '${jnldir}'/*.mjl* mumps.repl" mv nozip'		>& backup_secondary.log
$MSR RUN INST1 '$rcp bak1/* "$tst_now_secondary":"$SEC_SIDE/"'								>& ship.log
if ("ENCRYPT" == $test_encryption) then
	$MSR RUN INST1 '$rcp *_key "$tst_now_secondary":"$SEC_SIDE/"'							>& ship_keys.log
endif

echo "# Restart replication with updateresync"
$MSR STARTSRC INST1 INST2 RP												>& startsrc_restart.log
setenv needupdatersync 1
setenv test_jnl_on_file 1
$MSR STARTRCV INST1 INST2												>& startrcv_restart.log
unsetenv test_jnl_on_file
unsetenv needupdatersync

echo "# Allow some transactions to be generated while replication is back up"
$gtm_tst/com/wait_for_transaction_seqno.csh +2000 SRC 120 INSTANCE2 noerror

echo "# Stop updates"
$gtm_tst/com/endtp.csh													>& endtp.log
# Processes are done, so remove indicator.
unsetenv gtm_test_other_bg_processes

echo "# Final checks"
mkdir -p ${jnldir}.overflowed
mv ${jnldir}/* ${jnldir}.overflowed/
$gtm_com/IGS UMOUNT $jnldir
$grep -v "UMOUNT" ../cleanup.csh >&! ../cleanup.csh.filtered
mv ../cleanup.csh.filtered ../cleanup.csh

# Clean up expected errors
if ($?got_src_error) then
	foreach file (SRC_SHUT_${stopsrc_time}.out wfb_*.log)
		mv ${file} ${file}x
		$grep -v SRCSRVNOTEXIST ${file}x > ${file}
	end
endif
$gtm_tst/com/dbcheck.csh												>& final_checks.log
