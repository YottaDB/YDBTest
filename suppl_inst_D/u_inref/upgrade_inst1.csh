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
# Test that upgrading a backup of B which is an existing non-supplementary LMS group (A->B) to a supplementary instance (P)
# and resuming replication on P with A (i.e. A->P) is straightforward (while A->B is still live)
# and does not involve dse fiddling with seqnos.
#

# The gen_sym_key.sh setup will not work without significant modifications when databases are copied from HOST2 to HOST3 (but does
# work for transfers from HOST1 to HOST2). The issue is that the symmetric key, shared across all instances, is encrypted using
# either HOST2's or HOST3's public key signed with HOST1's private key; yet HOST2's and HOST3's keys are unsigned in regards to each
# other, and neither has participated in the encryption of the symmetric key used by the other.
if ("MULTISITE" == "$test_replic") setenv test_encryption "NON_ENCRYPT"
if (2 == $test_replic_mh_type) then
	source $gtm_tst/com/gtm_test_setbgaccess.csh # mupip reorg -upgrade requires BG access method
endif

$MULTISITE_REPLIC_PREPARE 2 2

# Randomly choose the 1, 2 or 3 regions.
@ db_num = `$gtm_exe/mumps -run rand 3 1 1`

echo
echo "Check the output of dbcreate in dbcreate.log"
setenv gtm_test_sprgde_id "ID${db_num}"	# to create/use different .sprgde files based on # of regions
$gtm_tst/com/dbcreate.csh mumps $db_num 125 1000 1024 4096 1024 4096 >&! dbcreate.log
echo
echo "===>Start replication A->B, A->P, P->Q"
echo

setenv needupdatersync 1
$MSR START INST1 INST2 RP
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP
unsetenv needupdatersync

$MSR STOPRCV INST3 INST4

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

# Now we want to upgrade a backup of B to P. So take a backup of B first
$MSR RUN INST2 'mkdir backup_inst2 ; $MUPIP backup -replinstance=backup_inst2 "*" -bkupdbjnl=disable backup_inst2 ' >&! inst2_bkup.log

if ("ENCRYPT" == "$test_encryption" ) then
	$MSR RUN INST2 'cp *_key backup_inst2' >&! inst2_bkup.log
endif



$MSR STOPRCV INST1 INST3
$MSR STOPSRC INST3 INST4

if (2 == $test_replic_mh_type) then
	$MSR RUN INST2 "cd backup_inst2 ; cp ../mumps.gld . ; $gtm_tst/$tst/u_inref/endiancvt_helper.csh ; rm mumps.gld " >>&! endiancvt_inst3.out
endif
$MSR RUN RCV=INST3 'mkdir backup_from_inst2 backup_inst3'
$MSR RUN SRC=INST2 RCV=INST3 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/backup_inst2/* _REMOTEINFO___RCV_DIR__/backup_from_inst2/'

# do rundown if needed before copying databases in a quiescent state.
$MSR RUN INST3 "set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0"
$MSR RUN INST3 '$gtm_tst/com/backup_dbjnl.csh backup_inst3 "*.dat mumps.repl" mv ; cp backup_from_inst2/* . ; mv mumps.repl srcinstback.repl ; $MUPIP replicate -instance -name=INSTANCE3 -supplementary $gtm_test_qdbrundown_parms' >&! instcreate.out
$MSR RUN INST3 '$MUPIP set -replication=on -reg "*"' >&! replic_on.out

$MSR STARTSRC INST3 INST4 RP

setenv needupdatersync 1
$MSR STARTRCV INST1 INST3
unsetenv needupdatersync

# Make few updates on the INST3.
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/imptp.csh' >&! imptp_inst3_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensure that there will be reasonable updates on instance A and P before switchover
sleep 1
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_1.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh' >&! endtp_inst3_1.out

echo
echo "Stop the test"
echo
$MSR SYNC INST1 INST2
$MSR SYNC INST1 INST3

$MSR STOP INST1 INST2
$MSR STOP INST1 INST3
$MSR STOPSRC INST3 INST4

# Since the instance file is recreated on INST3 and the database is copied from the INST2; INST3 and INST4 will not have the same global and also FETCHRESYNC ROLLBACK cant be done on the INST4
$gtm_tst/com/dbcheck.csh
