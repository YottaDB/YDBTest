#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2011, 2013 Fidelity Information Services, Inc	#
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
# Test that crashing the receiver server and update process in a particular fashion does not cause the receiver server to hang.
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

echo
$echoline
echo "Step 2 ===> Start some updates in the background..."
$echoline
setenv gtm_test_dbfill "SLOWFILL"	# SLOWFILL is chosen because we just want to spice up things a bit and not stress test replication
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

echo
$echoline
echo "Step 4 ===> Crash Receiver server"
$echoline
echo "Time before KILLing Receiver server - GTM_TEST_DEBUGINFO `date`"
# Get the process list just before and just after the kill
set psfile="psinfo_receiv.txt"
echo "=====> BEFORE KILLing $receivpid <=====" >>&! $psfile
$ps >>&! $psfile
$MSR RUN INST2 "set msr_dont_trace ; $kill9 $receivpid"
echo "=====> AFTER KILLing $receivpid <=====" >>&! $psfile
$ps >>&! $psfile
echo "Time after KILLing Receiver server - GTM_TEST_DEBUGINFO `date`"

echo
$echoline
echo "Step 5 ===> Bring back the receiver server with helper processes"
$echoline
$MSR RUN RCV=INST2 '$MUPIP replic -receiv -start -listen=__RCV_PORTNO__ -log=__RCV_DIR__/RCVR_restart.log -helper'
$echoline
echo "	Step 5a ===> Verify that receiver server detects an already existing update process"
$echoline
# The actual message we are looking for is : "YDB-I-TEXT, Update process already exists. Not starting it". However,
# check_error_exist.csh when passed a message string with spaces in it considers each of the individual words as
# seperate messages and prints the the check_error_exist template for each word which is not what we want. Instead,
# do the check_error_exist ONLY on YDB-I-TEXT
$MSR RUN RCV=INST2 '$gtm_tst/com/wait_for_log.csh -log RCVR_restart.log -message' "YDB-I-TEXT" -duration 120
$MSR RUN RCV=INST2 '$gtm_tst/com/check_error_exist.csh RCVR_restart.log' "YDB-I-TEXT"

# We are about to kill the update process. Make sure the update process is in a quiescent state before the kill. This is necessary
# as otherwise, the kill can reach the update process at the right time when it is in the midst of doing a PHASE2 commit (after
# incrementing cnl->wcs_phase2_commit_pidcnt). Subsequent startup of update process will NOW fail (in DBG) with an assert. In PRO
# cache-recovery will happen and so there won't be any issues.
echo
$echoline
echo "Step 6 ===> Shutdown background updates and SYNC"
$echoline
$gtm_tst/com/endtp.csh >>&! endtp.out
# It is possible that even though the two sides are sync'ed w.r.t backlog being 0, it is possible that the update process is still
# writing/flushing journal buffers and hence a kill -9 at this point could reach the update process while it is holding journal
# I/O lock. See <D9L04002809_passive_source_server_shutdown_timeout> for more details. So, before killing the update process make
# sure things are hardened to disk as well
$MSR SYNC INST1 INST2 sync_to_disk

echo
$echoline
echo "Step 7 ===> Crash Update process"
$echoline
echo "Time before KILLing Update process - GTM_TEST_DEBUGINFO `date`"
# Get the process list just before and just after the kill
set psfile="psinfo_updproc.txt"
echo "=====> BEFORE KILLing $updprocpid <=====" >>&! $psfile
$ps >>&! $psfile
$MSR RUN INST2 "set msr_dont_trace ; $kill9 $updprocpid"
echo "=====> AFTER KILLing $updprocpid <=====" >>&! $psfile
$ps >>&! $psfile
echo "Time after KILLing Update process - GTM_TEST_DEBUGINFO `date`"
$echoline
echo "	Step 7a ===> Verify that receiver server detects that the OLD update process is NO more ALIVE"
$echoline
# Even though the receiver server was started with RCVR_restart.log, the previous check_error_exist.csh invocation will move the
# RCVR_restart.log into RCVR_restart.logx file and that is where we should now be looking for the ALERT messages
$MSR RUN RCV=INST2 '$gtm_tst/com/wait_for_log.csh -log RCVR_restart.logx -message' "ALERT" -duration 120
echo "----------"
echo "Error ALERT seen in RCVR_restart.logx as expected:"
$MSR RUN RCV=INST2 '$grep ALERT RCVR_restart.logx | $head -n 1'	# There can be multiple ALERT messages. Get ONLY the first
echo "----------"
#
# Above section is the whole purpose of this test. After we crash the Update process, the receiver server will detect that it is NO more
# alive and will attempt doing a waitpid on it (to prevent the update process from becoming a zombie). In V5.4-002 and before, the
# waitpid was done with the child PID being 0 (due to a bug in receiver server initialization). Since the second receiver server also
# spawned helper processes, invoking waitpid with child PID 0 will hang until any of the child processes (in this case the helper procs)
# to change their state. Because of this, later attempt to restart ONLY the update process using -updateonly and any future commands will
# also hang. V5.4-002A fixes this by ensuring that the receiver server ALWAYS invokes waitpid with the PID of the most recent update
# process (taken from recvpool structure that is NOT yet removed and to which the receiver server has a handle to)
#
echo
$echoline
echo "Step 8 ===> Bring back ONLY the Update process"
$echoline
$MSR RUN INST2 '$MUPIP replic -receiv -start -updateonly'

echo
$echoline
echo "Step 9 ===> Verify that Receiver checkhealth comes out clean with NO hangs"
$echoline
$MSR RUN INST2 '$MUPIP replic -receiv -checkhealth >& checkhealth2.tmp ; cat checkhealth2.tmp' >& checkhealth2.out

echo
$echoline
echo "Step 10 ===> SYNC, STOP and VERIFY DATABASE EXTRACTs"
$echoline
echo
$MSR SYNC INST1 INST2
$MSR STOP INST1 INST2
$gtm_tst/com/dbcheck.csh -extract
