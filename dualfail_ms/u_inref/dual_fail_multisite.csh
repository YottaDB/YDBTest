#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
####################################################################################################################
# scenario of this test
#N1 and N2 are different nodes.
#Let's test one configuration:
#             |--> INST2 (N2)
#INST1 (N1) --|
#             |--> INST3 (N2)
#and do fail-over across. Since dual_fail is submitted via multi_machine, this test will be run across two hosts.
#
#        -----------------------------------------------------
#               INST1/A            INST2/B          INST3/C
#        -----------------------------------------------------
#Step 1:        (P)imptp(30sec)    (S)              (S)
#Step 2:         X                 (P)               -
#Step 3:        (S)                (P)imptp(30sec)  (S)
#Step 4:        (P)imptp(30sec)     X                X
#Step 5:         X                  X                X
#Step 6:        (P)imptp(30sec)    (S)              (S)
#
####################################################################################################################
#
# This test can only run with BG access method, so let's make sure that's what we have
source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh

source $gtm_tst/com/gtm_test_trigupdate_disabled.csh   # this test does a failover and so disable -trigupdate

# This test does a failover. A->P won't work in this case.
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif
#
$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh mumps 2 125 1000 1024
setenv gtm_test_tptype "ONLINE"
setenv gtm_process   5
setenv tst_buffsize 33000000
$MSR START INST1 INST2 RP
get_msrtime # sets time_msr to be used in wait for activation step below
$MSR START INST1 INST3 RP
setenv time_stamp `date +%H:%M:%S`
setenv gtm_test_jobid 1
$MSR RUN INST1 'setenv gtm_test_jobid 1; $gtm_tst/com/imptp.csh $gtm_process >>&! imptp_${time_stamp}.out'
sleep 30
$MSR CRASH INST1
$MSR STOP INST3
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP replic -receiv -shutdown -timeout=0 >&! shutdown12.out ; cat shutdown12.out'
$MSR REFRESHLINK INST1 INST2
$MSR ACTIVATE INST2 INST1 RP
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/wait_for_log.csh -log passive_${time_msr}.log -message 'Changing log file to SRC_activated'"
$MSR RUN RCV=INST1 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost1.glo "*" >&! rollback_1_2.out;$grep "Rollback successful" rollback_1_2.out'
$MSR RUN INST1 '$gtm_tst/com/dbcheck_base_filter.csh -nosprgde'
$MSR STARTRCV INST2 INST1
$MSR STARTSRC INST2 INST3 RP
$MSR RUN RCV=INST3 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost2.glo "*" >&! rollback_3_2.out;$grep "Rollback successful" rollback_3_2.out'
$MSR STARTRCV INST2 INST3
setenv time_stamp `date +%H:%M:%S`
$MSR RUN INST2 '$gtm_tst/com/imptp.csh '$gtm_process' >>&! imptp_'${time_stamp}'.out'
sleep 30
$MSR CRASH INST2
$MSR CRASH INST3
$MSR RUN RCV=INST1 SRC=INST2 '$MUPIP replic -receiv -shutdown -timeout=0 >&! shutdown21.out ; cat shutdown21.out'
$MSR REFRESHLINK INST2 INST1
$MSR ACTIVATE INST1 INST2 RP
setenv time_stamp `date +%H:%M:%S`
setenv gtm_test_jobid 2
$MSR RUN INST1 'setenv gtm_test_jobid 2; $gtm_tst/com/imptp.csh $gtm_process >>&! imptp_${time_stamp}.out'
sleep 30
$MSR CRASH INST1
$MSR RUN INST1 '$gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo "*" >&! rollback_1.out;$grep "Rollback successful" rollback_1.out'
$MSR STARTSRC INST1 INST2
# rollback the crashed instance INST2
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost2.glo "*" >&! rollback_2_1.out;$grep "Rollback successful" rollback_2_1.out'
$MSR STARTRCV INST1 INST2
$MSR STARTSRC INST1 INST3
# we already crashed INST3 so we need to roll it back as well
$MSR RUN RCV=INST3 SRC=INST1 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost3.glo "*" >&! rollback_3_1.out;$grep "Rollback successful" rollback_3_1.out'
$MSR STARTRCV INST1 INST3
setenv time_stamp `date +%H:%M:%S`
setenv gtm_test_jobid 3
$MSR RUN INST1 'setenv gtm_test_jobid 3; $gtm_tst/com/imptp.csh $gtm_process >>&! imptp_${time_stamp}.out'
sleep 30
$MSR RUN INST1 '$gtm_tst/com/endtp.csh >>&! endtp_${time_stamp}.out'
$MSR SYNC ALL_LINKS
$gtm_tst/com/dbcheck_filter.csh -extract INST1 INST2 INST3
#
