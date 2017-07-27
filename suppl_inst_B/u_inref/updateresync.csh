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

# Tests for -updateresync qualifier usage error.
#

$MULTISITE_REPLIC_PREPARE 4 1
$gtm_tst/com/dbcreate.csh mumps -rec=1000

echo "# A non-supplementary replicating receiver will report the error UPDSYNC2MTINS if its instance file is not empty."
setenv needupdatersync 1
$MSR START INST1 INST2 RP
unsetenv needupdatersync
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 1
$MSR SYNC ALL_LINKS
$MSR STOP ALL_LINKS
$MSR STARTSRC INST1 INST2 RP
$MSR STARTRCV INST1 INST2 "updateresync -initialize"
get_msrtime
$MSR RUN INST2 "$msr_err_chk START_$time_msr.out UPDSYNC2MTINS NORECVPOOL"
$gtm_tst/com/knownerror.csh $msr_execute_last_out GTM-E-UPDSYNC2MTINS
$gtm_tst/com/knownerror.csh $msr_execute_last_out GTM-E-NORECVPOOL
# the receiver will be shut down but the passive server will be alive. Manually stop it
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__  >&! passivesrc_shut_INST1INST2.out'
$MSR STOP ALL_LINKS

echo "# A supplementary replicating receiver will report the error INSUNKNOWN if its instance file is empty."
$MSR STARTSRC INST5 INST3 RP # INST3 is used for a dummy name.
$MSR STARTSRC INST1 INST5 RP
setenv gtm_test_repl_skiprcvrchkhlth 1 ; $MSR STARTRCV INST1 INST5 >&! STARTRCV_INST1_INST5.outx ; unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST5 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message INSUNKNOWN -duration 120 -waitcreation'
$MSR RUN INST5 "$msr_err_chk RCVR_$time_msr.log INSUNKNOWN"
# Receiver server would have exited with the above error. Manually shutdown update process
$gtm_tst/com/knownerror.csh $msr_execute_last_out GTM-E-INSUNKNOWN
$MSR RUN INST5 'set msr_dont_chk_stat ; $MUPIP replic -receiver -shutdown -timeout=0 >&! updateproc_shut_INST1INST5.out'
$MSR STOPSRC INST5 INST3
$MSR STOPSRC INST1 INST5
$MSR REFRESHLINK INST1 INST5

echo "# report the error RCVRAHEADOFSRC if it is specified on a receiver with a max-reg-seqno value greater than the source"
setenv needupdatersync 1
$MSR START INST3 INST4 RP
unsetenv needupdatersync
$gtm_tst/com/simplegblupd.csh -instance INST3 -count 50        # seqnos: (2-51)
$MSR SYNC INST3 INST4
$MSR RUN INST3 "mkdir bak1; $MUPIP backup -replinstance=bak1 "'"*" bak1 >&! backup_replinstance_bak1.out'
$gtm_tst/com/simplegblupd.csh -instance INST3 -count 50        # seqnos: (52-101)
$MSR STOP INST3 INST4
$MSR RUN INST3 "set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 ; cp -p bak1/* ."
$MSR STARTSRC INST3 INST4
setenv gtm_test_repl_skiprcvrchkhlth 1 ; $MSR STARTRCV INST3 INST4 >&! STARTRCV_INST3_INST4.outx ; unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST4 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message "Received REPL_ROLLBACK_FIRST message" -duration 120 -waitcreation'
$MSR RUN INST4 'set msr_dont_trace ; $gtm_tst/com/wait_until_srvr_exit.csh rcvr'
# the receiver will be shut down but the passive server will be alive. Manually stop it
$MSR RUN RCV=INST4 SRC=INST3 '$MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__  >&! passivesrc_shut_INST3INST4.out'
$MSR STOPSRC INST3 INST4
$MSR REFRESHLINK INST3 INST4

# The instances are not expected to be in sync. So -extract should not be needed
$gtm_tst/com/dbcheck.csh
