#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that replication between P->Q is robust when there are multiple switchover bwtween A and B resulting in multiple
# history records in the instance file on P
#

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

# Switch over from A to B
echo "Switch over from A to B"
#Stop updates on A
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_1.out
$MSR STOP INST1 INST2
$MSR STOP INST1 INST3
$MSR START INST2 INST1 RP
$MSR START INST2 INST3 RP
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst2_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensure that there will be reasonable updates on instance A and P before switchover
sleep 1

# Shut down Q side of P->Q link
echo "Shut down Q side of P->Q link"
$MSR STOPRCV INST3 INST4

# Switch over back from B to A
echo "Switch over back from B to A"
#Stop updates on B
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst2_1.out
$MSR STOP INST2 INST1
$MSR STOP INST2 INST3
$MSR START INST1 INST2 RP
$MSR START INST1 INST3 RP
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_2.out
# Following sleep along with environment variable gtm_test_wait_factor ensure that there will be reasonable updates on instance A and P before switchover
sleep 1

# Switch over from A to B
echo "Switch over from A to B"
#Stop updates on A
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_2.out
$MSR STOP INST1 INST2
$MSR STOP INST1 INST3
$MSR START INST2 INST1 RP
$MSR START INST2 INST3 RP
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst2_2.out
# Following sleep along with environment variable gtm_test_wait_factor ensure that there will be reasonable updates on instance A and P before switchover
sleep 1

# Switch over back from B to A
echo "Switch over back from B to A"
#Stop updates on B
$MSR RUN INST2 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst2_2.out
$MSR STOP INST2 INST1
$MSR STOP INST2 INST3
$MSR START INST1 INST2 RP
$MSR START INST1 INST3 RP
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_3.out
# Following sleep along with environment variable gtm_test_wait_factor ensure that there will be reasonable updates on instance A and P before switchover
sleep 1

# Restart Q side of P->Q link
echo "Restart down Q side of P->Q link"
$MSR STARTRCV INST3 INST4

#Stop updates on A and P
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_3.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh' >&! endtp_inst3_1.out

#wait for zero backlog on all links
$MSR SYNC ALL_LINKS

echo
echo "===>Do showbacklog on A->B side"
echo
$MSR SHOWBACKLOG INST1 INST2 SRC

echo
echo "===>Do showbacklog on P->Q side"
echo
$MSR SHOWBACKLOG INST3 INST4 SRC

echo
echo "===>Do showbacklog on A->P side"
echo
$MSR SHOWBACKLOG INST1 INST3 SRC

$gtm_tst/com/dbcheck.csh -extract
