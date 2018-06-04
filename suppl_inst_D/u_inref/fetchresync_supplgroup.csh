#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test -fetchresync rollback between A and B AND P and Q (both instaces from same group)
#

setenv gtm_test_dbfill "SLOWFILL"
source $gtm_tst/com/gtm_test_setbeforeimage.csh
if ("ENCRYPT" == "$test_encryption") then
	# This test has had RF_sync issues which showed the servers stuck in BF_encrypt() for a long time
	# Disabling BLOWFISHCFB since it seems to be a known issue with BLOWFISHCFB - Check <rf_sync_timeout_BF_encrypt>
	# It is easier to re-randomize than to check if gtm_crypt_plugin is set and if so check if it points to BLOWFISHCFB
	unsetenv gtm_crypt_plugin
	setenv gtm_test_exclude_encralgo BLOWFISHCFB
	echo "# Encryption algorithm re-randomized by the test"	>>&! settings.csh
	source $gtm_tst/com/set_encryption_lib_and_algo.csh	>>&! settings.csh
endif
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

source $gtm_tst/com/set_gtm_test_wait_factor.csh	# set gtm_test_wait_factor env var to control SLOWFILL rate of updates

echo
echo "===>Do some updates on A and P and let them replicate to B, P and Q as appropriate"
echo
# The first digit in jobid and dibfillid indicates the instance ID while second digits indicates number of times updates are started on the given instance.
$MSR RUN INST1 'setenv gtm_test_jobid 11 ; setenv gtm_test_dbfillid 11 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_1.out
$MSR RUN INST3 'setenv gtm_test_jobid 31 ; setenv gtm_test_dbfillid 31 ; $gtm_tst/com/imptp.csh' >&! imptp_inst3_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1

setenv gtm_test_other_bg_processes

# Switch over from A to B
echo "Switch over from A to B"
#Stop updates on A
$MSR RUN INST1 'setenv gtm_test_jobid 11 ; setenv gtm_test_dbfillid 11 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_1.out
$MSR STOP INST1 INST2
$MSR STOP INST1 INST3
$MSR STARTSRC INST2 INST1 RP
$MSR RUN INST2 'setenv gtm_test_jobid 21 ; setenv gtm_test_dbfillid 21 ; $gtm_tst/com/imptp.csh' >&! imptp_inst2_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1
$MSR RUN RCV=INST1 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost1.glo "*" >&! rollback_1.out; $grep "Rollback successful" rollback_1.out'
$MSR STARTRCV INST2 INST1
$MSR START INST2 INST3 RP

# Switch over from P to Q
echo "Switch over from P to Q"
#Stop updates on B and P
$MSR RUN INST2 'setenv gtm_test_jobid 21 ; setenv gtm_test_dbfillid 21 ; $gtm_tst/com/endtp.csh' >&! endtp_inst2_1.out
$MSR RUN INST3 'setenv gtm_test_jobid 31 ; setenv gtm_test_dbfillid 31 ; $gtm_tst/com/endtp.csh' >&! endtp_inst3_1.out
$MSR STOP INST2 INST3
$MSR STOP INST3 INST4
$MSR RUN INST2 'setenv gtm_test_jobid 22 ; setenv gtm_test_dbfillid 22 ; $gtm_tst/com/imptp.csh' >&! imptp_inst2_2.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1
$MSR STARTSRC INST4 INST3 RP
$MSR RUN INST4 'setenv gtm_test_jobid 41 ; setenv gtm_test_dbfillid 41 ; $gtm_tst/com/imptp.csh' >&! imptp_inst4_1.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1
$MSR RUN RCV=INST3 SRC=INST4 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost1.glo "*" >&! rollback_2.out; $grep "Rollback successful" rollback_2.out'
$MSR STARTRCV INST4 INST3
$MSR START INST2 INST4 RP

# Switch over back from B to A
echo "Switch over back from B to A"
#Stop updates on B
$MSR RUN INST2 'setenv gtm_test_jobid 22 ; setenv gtm_test_dbfillid 22 ; $gtm_tst/com/endtp.csh' >&! endtp_inst2_2.out
$MSR STOP INST2 INST1
$MSR STOP INST2 INST4
$MSR STARTSRC INST1 INST2 RP
$MSR RUN INST1 'setenv gtm_test_jobid 12 ; setenv gtm_test_dbfillid 12 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_2.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost1.glo "*" >&! rollback_3.out; $grep "Rollback successful" rollback_3.out'
$MSR STARTRCV INST1 INST2
$MSR START INST1 INST4 RP

# Switch over back from Q to P
echo "Switch over back from Q to P"
#Stop updates on A and Q
$MSR RUN INST4 'setenv gtm_test_jobid 41 ; setenv gtm_test_dbfillid 41 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_1.out
$MSR RUN INST1 'setenv gtm_test_jobid 12 ; setenv gtm_test_dbfillid 12 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_2.out
$MSR STOP INST1 INST4
$MSR STOP INST4 INST3
$MSR RUN INST1 'setenv gtm_test_jobid 13 ; setenv gtm_test_dbfillid 13 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_3.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1
$MSR STARTSRC INST3 INST4 RP
$MSR RUN INST3 'setenv gtm_test_jobid 32 ; setenv gtm_test_dbfillid 32 ; $gtm_tst/com/imptp.csh' >&! imptp_inst3_2.out
# Following sleep along with environment variable gtm_test_wait_factor ensures that there will be reasonable updates on instance A and P before switchover
sleep 1
$MSR RUN RCV=INST4 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost1.glo "*" >&! rollback_4.out; $grep "Rollback successful" rollback_4.out'
$MSR STARTRCV INST3 INST4
$MSR START INST1 INST3 RP

unsetenv gtm_test_other_bg_processes

#Stop updates on A and P
$MSR RUN INST1 'setenv gtm_test_jobid 13 ; setenv gtm_test_dbfillid 13 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_3.out
$MSR RUN INST3 'setenv gtm_test_jobid 32 ; setenv gtm_test_dbfillid 32 ; $gtm_tst/com/endtp.csh' >&! endtp_inst3_2.out

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
