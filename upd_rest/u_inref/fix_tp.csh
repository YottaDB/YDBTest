#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : S9908-001327 Update process died on receiving TRETRY signal
#
# ########################################################
# This gives too many RESTARTS and horrible replication performance
# $gtm_tst/com/dbcreate.csh mumps 1 125 1000 1024 100 128
$gtm_tst/com/dbcreate.csh mumps 2 125 1000 512,768,1024 2048 512 500
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
if !($?gtm_test_replay) then
	set helper_rand = `$gtm_exe/mumps -run rand 2`
	set do_overflow = `$gtm_exe/mumps -run rand 2`
	echo "# Helper and overflow choise chosen by subtest"	>>&! settings.csh
	echo "setenv helper_rand $helper_rand"			>>&! settings.csh
	echo "setenv do_overflow $do_overflow"			>>&! settings.csh
endif
if ($helper_rand) then
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP  replicate -receive -start -helpers >& helpers_start.out"
endif
echo "GTM Process starts in background..."
setenv gtm_test_dbfill "FIXTP"	# TP size is constant in the fill program
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
# Instead of just sleeping, wait for the number of transactions to appear in the source log, and use
# the sleep time as a wait limit.
# This number is the multiplier for the number of transactions to expect in a second, which is set to be
# more than what a slow machine can produce, but somewhat less than what a fast machine can.
@ tps = 5000
@ transcount = ${test_sleep_sec_short} * ${tps}
$gtm_tst/com/wait_for_transaction_seqno.csh +${transcount} SRC ${test_sleep_sec_short} "" "noerror"
if ($do_overflow) then
	# Force the receiver down
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
	# Wait for Journal Pool to overflow, forcing file read on reconnect.
	$gtm_exe/mumps -run waitforjpofl
	# Start the secondary
	setenv start_time `date +%H_%M_%S`
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $start_time < /dev/null "">>&! "" $SEC_SIDE/START_${start_time}.out"
endif
#
if ("HOST_AIX_RS6000" == $gtm_test_os_machtype) then
	$gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log -message "Update Process started" -duration 300
	cd $SEC_SIDE
	$sec_getenv
	set pidupd = `$MUPIP replicate -receiv -checkhealth |& $tst_awk '/PID.*Update/{printf(" %s", $2);}'`
	cd $PRI_SIDE
	($gtm_tst/$tst/u_inref/introspect_secondary_jobs.csh $pidupd &) >&! introspection.out
endif
# Now force retries
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/fix_tp_rest.csh >>& fix_tp_rest.out"
echo "Now GTM process will end."
$gtm_tst/com/endtp.csh >>& endtp.out
# The purpose of the test is to induce RESTARTS in the secondary by doing concurrent reads while update proces is running.
# Ensure that there are some TPRETRY messages seen in the update process log.
$grep "TPRETRY" $SEC_SIDE/RCVR_${start_time}.log.updproc >&! TPRETRY_updproc.outx
set stat=$status
if (0 != $status) then
	echo "TEST-E-NOTPRETRY - No TPRETRY messages found in the update process log."
endif
$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/checkdb.csh
