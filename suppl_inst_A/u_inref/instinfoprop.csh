#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# 5) Test that instance information propagation is not instantaneous
# Let us take the following instance layout.
# P->Q is a supplementary group generating its own set of updates (in P). Let us say Q has a backlog of a million transactions.
# Now let connects A->P. This makes P aware of A but Q does not yet know about A.
# Then let P->Q replication continue for a while but the million backlog should NOT be cleared.
# At this point, bring P down and start Q as the root primary. Now if you connect it to A, we expect an error that Q does not
# know about A. Now redo the data load and connect A->Q. And then run a fetchresync rollback on P to connect it
# as a secondary to Q. Things should replicate fine from Q to P without any issues.
# This ensures replication health is not affected by the same LOADINST happening in different instances of the same LMS group.

source $gtm_tst/com/gtm_test_setbeforeimage.csh

$MULTISITE_REPLIC_PREPARE 1 2
$gtm_tst/com/dbcreate.csh mumps -rec=1000


setenv needupdatersync 1
$MSR START INST2 INST3 RP
unsetenv needupdatersync
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 1
$MSR SYNC INST2 INST3
$MSR STOP INST2 INST3
$MSR STARTSRC INST2 INST3 RP
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 1000000 >>& huge_backlog.log
$MSR STARTRCV INST2 INST3
setenv needupdatersync 1
$MSR START INST1 INST2 RP
get_msrtime
unsetenv needupdatersync
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log RCVR_'${time_msr}'.log -message "History has non-zero Supplementary Stream" -duration 30'
$MSR STOP INST1 INST2
$MSR STOP INST2 INST3
$MSR STARTSRC INST3 INST2 RP
# INST3 receiver start will fail because it doesn't yet know about INST1, so we will retry with updateresync after that
$MSR STARTSRC INST1 INST3 RP
setenv gtm_test_repl_skiprcvrchkhlth 1 ; $MSR STARTRCV INST1 INST3 >&! STARTRCV_INST1_INST3.outx ; unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST3 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message INSUNKNOWN -duration 120 -waitcreation'
$MSR RUN INST3 "$msr_err_chk RCVR_$time_msr.log INSUNKNOWN"
# Receiver server would have exited with the above error. Manually shutdown update process
$gtm_tst/com/knownerror.csh $msr_execute_last_out GTM-E-INSUNKNOWN
$MSR RUN INST3 'set msr_dont_chk_stat ; $MUPIP replic -receiver -shutdown -timeout=0 >&! updateproc_shut_INST1INST3.out'
$MSR STOPSRC INST1 INST3
$MSR STOPSRC INST3 INST2
$MSR RUN INST3 'set msr_dont_trace ; $gtm_tst/com/backup_dbjnl.csh bak_b4rlbk "*.dat *.mjl* *.gld *.repl" "cp" nozip'
$MSR RUN INST3 '$gtm_tst/com/mupip_rollback.csh -verbose "*"' >&rollback_failed_conn.logx
$MSR STARTSRC INST3 INST2 RP
setenv needupdatersync 1
$MSR START INST1 INST3 RP
unsetenv needupdatersync
$MSR RUN INST2 'set msr_dont_trace ; $gtm_tst/com/backup_dbjnl.csh bak_b4rlbk "*.dat *.mjl* *.gld *.repl" "cp" nozip'
$MSR RUN RCV=INST2 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=lost_INST2.glo "*"' >& rollback_INST2.log
$MSR STARTRCV INST3 INST2
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 10
$MSR STOP ALL_LINKS

$gtm_tst/com/dbcheck.csh
