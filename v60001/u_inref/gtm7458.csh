#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that crashing the receiver server and update process in a particular fashion does not cause REPLREQROLLBACK errors during
# subsequent startup
#
$echoline
echo "Step 1 ===> Prepare a MSR configuration with two instances"
$echoline
$MULTISITE_REPLIC_PREPARE 2
# Since the receiver is explicitly restarted without -tlsid, the source server (if started with -tlsid) would error out with
# REPLNOTLS. To avoid that, allow for the source server to fallback to plaintext when that happens.
setenv gtm_test_plaintext_fallback
$gtm_tst/com/dbcreate.csh mumps
$MSR START INST1 INST2 RP
get_msrtime

echo
$echoline
echo "Step 2 ===> Start some updates in the background..."
$echoline
setenv gtm_test_dbfill "SLOWFILL"	# SLOWFILL is chosen because we just want to spice up things a bit and not stress test
					# replication
$gtm_tst/com/imptp.csh >>&! imptp.out

echo
$echoline
echo "Step 3 ===> Get the PID of the update process and receiver server"
$echoline
$MSR RUN INST2 '$MUPIP replic -receiver -checkhealth >& checkhealth.tmp ; cat checkhealth.tmp' >& checkhealth.out
set receivpid = `$tst_awk '/PID.*Receiver/{print $2}' checkhealth.out`
set updprocpid = `$tst_awk '/PID.*Update process/{print $2}' checkhealth.out`
echo "=====> Receiver server PID = GTM_TEST_DEBUGINFO $receivpid <====="
echo "=====> Update process PID = GTM_TEST_DEBUGINFO $updprocpid <====="

$MSR RUN INST2 '$MUPIP replic -editinstance -show mumps.repl' >&! receiver_inst_show_before.txt	# For aid in debugging

echo
$echoline
echo "Step 4 ===> Stop IMPTP, Crash Update Process & MUPIP STOP Receiver Server"
$echoline
$gtm_tst/com/endtp.csh >>&! endtp.out
$MSR SYNC INST1 INST2 sync_to_disk
echo "Time before KILLing Update Process - GTM_TEST_DEBUGINFO `date`"
set psfile="psinfo_kills.txt"
echo "=====> BEFORE KILLing $updprocpid <=====" >>&! $psfile
$ps >>&! $psfile
$MSR RUN INST2 "set msr_dont_trace ; $kill9 $updprocpid"
echo "=====> AFTER KILLing $updprocpid <=====" >>&! $psfile
$ps >>&! $psfile
echo "Time after KILLing Update Process - GTM_TEST_DEBUGINFO `date`"
# Manually unfreeze because the process who set the freeze might have been killed. In our design, only the process who detected
# ENOSPC and set the freeze can automatically unfreeze the instance. Killing it will cause the instance to stay frozen.
$MSR RUN INST2 '$MUPIP'" replicate -source -freeze=off"

echo "=====> BEFORE MUPIP STOP $receivpid <=====" >>&! $psfile
$ps >>&! $psfile
$MSR RUN INST2 "$MUPIP stop $receivpid >&! mupip_stop_receiver.out" |& sed 's/mupip stop [0-9]*/mupip stop ##FILTERED##/g'
$MSR RUN INST2 'set msr_dont_trace ; $gtm_tst/com/wait_for_proc_to_die.csh' $receivpid 120
echo "=====> AFTER MUPIP STOP $receivpid <=====" >>&! $psfile
$ps >>&! $psfile
echo "Time after MUPIP STOP Receiver Server - GTM_TEST_DEBUGINFO `date`"
$MSR RUN INST2 "set msr_dont_trace; $msr_err_chk RCVR_${time_msr}.log FORCEDHALT"
$msr_err_chk $msr_execute_last_out YDB-F-FORCEDHALT

$MSR RUN INST2 '$MUPIP replic -editinstance -show mumps.repl' >&! receiver_inst_show_after.txt	# For aid in debugging

echo
$echoline
echo "Step 5 ===> Bring back the Receiver Server"
$echoline
$MSR RUN INST2 '$MUPIP replic -receiver -start -listen=__SRC_PORTNO__ -log=receiver_restart.log'
$echoline
echo "Step 6 ===> SYNC/VERIFY/STOP both ends"
$echoline
$MSR SYNC INST1 INST2
$MSR STOP INST1 INST2
$gtm_tst/com/dbcheck.csh -extract
