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
# Test that upgrading B (in an existing non-supplementary LMS group A->B) in-place from a non-supplementary to a supplementary
# instance and resuming replication with A is straightforward and does not involve dse fiddling with seqnos.
#

source $gtm_tst/com/gtm_test_setbeforeimage.csh
$MULTISITE_REPLIC_PREPARE 2

# Randomly choose the 1, 2 or 3 regions.
@ db_num = `$gtm_exe/mumps -run rand 3`
@ db_num = $db_num + 1

echo
echo "Check the output of dbcreate in dbcreate.log"
# Since the receiver is explicitly restarted without -tlsid, the source server (if started with -tlsid) would error out with
# REPLNOTLS. To avoid that, allow for the source server to fallback to plaintext when that happens.
setenv gtm_test_plaintext_fallback
setenv gtm_test_sprgde_id "ID${db_num}"	# to create/use different .sprgde files based on # of regions
$gtm_tst/com/dbcreate.csh mumps $db_num 125 1000 1024 4096 1024 4096 >&! dbcreate.log

echo
echo "===>Start replication A->B"
echo
$MSR START INST1 INST2 RP

# Also because this test does SLOWFILL type of updates, we need to have a very small inter-update time (gtm_test_wait_factor)
# in order to exercise jnl autoswitch. But because we do not want a lot of updates, the inter-update time should not be too
# low either. Therefore we currently maintain it at 0.02. This value needs to be changed with care.
setenv gtm_test_wait_factor 0.02 # 0.02 second delay between updates in slowfill.m. See comment above for why it is what it is

echo
echo "===>Do some updates on A and let them replicate to B."
echo
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensure that there will be reasonable updates on instance A and P before switchover
sleep 1

$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_1.out
$MSR SYNC INST1 INST2
# Shut receiver side of A->B connection
$MSR STOPRCV INST1 INST2
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_2.out

# Rename instance file on INST2 to be used later in -updateresync command
$MSR RUN INST2 "set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 ; mv mumps.repl binst.repl"

echo "# Recreate instance file with -supplementary option"
$MSR RUN INST2 "set msr_dont_trace ; $MUPIP replicate -instance -name=INSTANCE2 -supplementary $gtm_test_qdbrundown_parms"

# Start receiver side of A->B
$MSR RUN INST2 "$MUPIP replic -source -start -passive -log=passive_source.log -buf=1 -instsecondary=INSTANCE1 -updok"
$MSR RUN RCV=INST2 SRC=INST1 "$MUPIP replic -receiv -start -listen=__RCV_PORTNO__ -log=receiver_restart.log -buf=$tst_buffsize -updateresync=binst.repl -initialize"

$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_2.out
$MSR SYNC INST1 INST2
$MSR STOPRCV INST1 INST2

$gtm_tst/com/dbcheck.csh -extract
