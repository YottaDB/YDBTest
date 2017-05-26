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
#
# Test -fetchresync rollback between A and P(non-supplementary and supplementary respectively)
#

source $gtm_tst/com/gtm_test_setbeforeimage.csh
$MULTISITE_REPLIC_PREPARE 2 2

# Randomly choose the 1, 2 or 3 regions.
@ db_num = `$gtm_exe/mumps -run rand 3`
@ db_num = $db_num + 1

echo
echo "Check the output of dbcreate in dbcreate.log"
echo
setenv gtm_test_sprgde_id "ID${db_num}"	# to create/use different .sprgde files based on # of regions
$gtm_tst/com/dbcreate.csh mumps $db_num 125 1000 1024 4096 1024 4096 >&! dbcreate.log

echo
echo "===>Start replication A->B, P->Q and A->P"
echo
setenv needupdatersync 1
$MSR START INST1 INST2 RP
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP
unsetenv needupdatersync

# Also because this test does SLOWFILL type of updates, we need to have a very small inter-update time (gtm_test_wait_factor)
# in order to exercise jnl autoswitch. But because we do not want a lot of updates, the inter-update time should not be too
# low either. Therefore we currently maintain it at 0.02. This value needs to be changed with care.
setenv gtm_test_wait_factor 0.02 # 0.02 second delay between updates in slowfill.m. See comment above for why it is what it is

echo
echo "===>Do some updates on A and P and let them replicate to B, P and Q as appropriate"
echo
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_1.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/imptp.csh' >&! imptp_inst3_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensure that there will be reasonable updates on instance A and P before switchover
sleep 1

setenv gtm_test_other_bg_processes

# Switch over from A to B
echo
echo "Switch over from A to B"
echo
#Stop updates on A
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_1.out
$MSR SYNC INST1 INST2
$MSR STOP INST1 INST2
$MSR STOP INST1 INST3
$MSR RUN  INST1 "mkdir bak1; $MUPIP backup -replinstance=bak1 "'"*" bak1' >&! inst1_bkup.log
$MSR START INST2 INST1 RP
$MSR START INST2 INST3 RP
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst2_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensure that there will be reasonable updates on instance A and P before switchover
sleep 1

# Switch over from P to Q
echo
echo "Switch over from P to Q"
echo
#Stop updates on B and P
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst2_1.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh' >&! endtp_inst3_1.out
$MSR STOP INST2 INST3
$MSR STOP INST3 INST4
$MSR START INST4 INST3 RP
$MSR START INST2 INST4 RP
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst2_2.out
$MSR RUN INST4 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/imptp.csh' >&! imptp_inst4_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensure that there will be reasonable updates on instance A and P before switchover
sleep 1

# Switch over back from B to A
echo
echo "Switch over back from B to A"
echo
#Stop updates on B
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst2_2.out
$MSR SYNC INST2 INST1
$MSR STOP INST2 INST1
$MSR STOP INST2 INST4
$MSR RUN  INST2 "mkdir bak1; $MUPIP backup -replinstance=bak1 "'"*" bak1' >&! inst2.bkup.log
$MSR START INST1 INST2 RP
$MSR START INST1 INST4 RP
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_2.out
# Following sleep along with environment variable gtm_test_wait_factor ensure that there will be reasonable updates on instance A and P before switchover
sleep 1

# Switch over back from Q to P
echo
echo "Switch over back from Q to P"
echo
#Stop updates on A and Q
$MSR RUN INST4 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh' >&! endtp_inst4_1.out
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_2.out
$MSR STOP INST1 INST4
$MSR STOP INST4 INST3
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP

unsetenv gtm_test_other_bg_processes

#wait for zero backlog on links from non-supplementary group
$MSR SYNC INST1 INST2
$MSR SYNC INST1 INST3
$MSR STOPRCV INST1 INST2

echo
echo "Take the snapshot of INST3 to restore later"
echo
$MSR STOP INST1 INST3
$MSR STOP INST3 INST4
$MSR RUN INST3 'set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh '$0' ; $gtm_tst/com/backup_dbjnl.csh bak1 "*.dat *.mjl* *.repl" "cp" nozip'
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP

echo
echo "test case 1: Do fetchresync Rollback on P while A is source server"
echo

$MSR STOP INST1 INST3
$MSR STOP INST3 INST4
$MSR STOPSRC INST1 INST2
$MSR RUN INST1 'set msr_dont_trace ; $gtm_tst/com/backup_dbjnl.csh bak2 "*.dat *.mjl* *.repl" "" nozip; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh '$0' ; cp bak1/* .'
$MSR STARTSRC INST3 INST4 RP
$MSR STARTSRC INST1 INST3 RP

# Try restarting receiver side of A->P. It should NOT replicate fine.
# But before that rename receiver log so later search for REPL_ROLLBACK_FIRST looks at just the new receiver startup and
# not prior startup logs.
$MSR RUN RCV=INST3 SRC=INST1 "$MUPIP replic -receiv -start -listen=__RCV_PORTNO__ -log=receiver_restart.log -buf=$tst_buffsize"
$MSR RUN RCV=INST3 SRC=INST1 '$gtm_tst/com/wait_for_log.csh -log receiver_restart.log -message "Received REPL_ROLLBACK_FIRST message" -duration 120 -waitcreation'
$MSR RUN INST3 'set msr_dont_trace ; $gtm_tst/com/wait_until_srvr_exit.csh rcvr'

$MSR STOPSRC INST3 INST4 RP
$MSR RUN RCV=INST3 SRC=INST1 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=lost1_INST1_1.glo "*"' >&! fetchresync_rb2.log

$MSR STARTSRC INST3 INST4 RP
$MSR STARTRCV INST1 INST3
$MSR SYNC INST1 INST3

echo
echo "test case 2: Do fetchresync Rollback on P while B is source server"
echo
$MSR STOP INST1 INST3
$MSR STOPSRC INST3 INST4
$MSR RUN INST2 'set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh '$0' ; cp -p bak1/*.* .'
$MSR RUN INST3 'set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh '$0' ; cp -p bak1/*.* .'
$MSR RUN INST1 'set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh '$0' ; cp -p bak2/*.* .'

# A <-> B
$MSR STARTSRC INST3 INST4 RP
$MSR STARTSRC INST2 INST3 RP
$MSR STARTSRC INST2 INST1 RP

# Try restarting receiver side of A->P. It should NOT replicate fine.
# But before that rename receiver log so later search for REPL_ROLLBACK_FIRST looks at just the new receiver startup and
# not prior startup logs.
$MSR RUN RCV=INST3 SRC=INST2 "$MUPIP replic -receiv -start -listen=__RCV_PORTNO__ -log=receiver_restart1.log -buf=$tst_buffsize"
$MSR RUN RCV=INST3 SRC=INST2 '$gtm_tst/com/wait_for_log.csh -log receiver_restart1.log -message "Received REPL_ROLLBACK_FIRST message" -duration 120 -waitcreation >&! recv_restart1.log ; cat recv_restart1.log ' >&! recv_restart_log1.outx
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out REPL_ROLLBACK_FIRST
$gtm_tst/com/check_error_exist.csh recv_restart_log1.outx REPL_ROLLBACK_FIRST
$MSR RUN INST3 'set msr_dont_trace ; $gtm_tst/com/wait_until_srvr_exit.csh rcvr'

# Do few rollback to bring all the sources and receivers in sync. So that dbcheck at the end of test will pass.
$MSR STOPSRC INST3 INST4 RP
$MSR RUN RCV=INST3 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=lost1_INST2_2.glo "*"' >&! fetchresync_rb3.log

# To avoid extract failure at the end
$MSR RUN RCV=INST1 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=lost1_INST3_3.glo "*"' >&! fetchresync_rb4.log

$MSR STARTSRC INST3 INST4 RP
$MSR RUN RCV=INST4 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=lost1_INST4_4.glo "*"' >&! fetchresync_rb5.log

$MSR STARTRCV INST2 INST3
$MSR STARTRCV INST2 INST1
$MSR STARTRCV INST3 INST4
$MSR SYNC INST2 INST3
$MSR SYNC INST2 INST1
$MSR SYNC INST3 INST4

echo
echo "===>Do showbacklog on B->A side"
echo
$MSR SHOWBACKLOG INST2 INST1 SRC

echo
echo "===>Do showbacklog on P->Q side"
echo
$MSR SHOWBACKLOG INST3 INST4 SRC

echo
echo "===>Do showbacklog on B->P side"
echo
$MSR SHOWBACKLOG INST2 INST3 SRC

echo
echo "===>Stop all links"
echo

$MSR STOP INST2 INST3
$MSR STOP INST2 INST1
$MSR STOP INST3 INST4

$gtm_tst/com/dbcheck_filter.csh -extract
