#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
# Helpers can cause the STEP 3 rollback to have lost transactions, disturbing the outref, so disable them.
setenv gtm_test_updhelpers 0

cat << EOF
## ## multisite_replic/instance_file_cycle -- design tests -- Final Example			###4###Kishore
## Implement the "Final Example" (Section 6.1.2.3) from the design spec.
## Details:
## --------------
## This is to illustrate the need for the cycle field in the triple.
##         ------------------------------------------------------
##                INST1/A      INST2/B      INST3/C      INST4/D
##         ------------------------------------------------------
## Step 1:      (P)  1-100   (S)  1-100        X             X
## Step 2:      (S)  1             X      (P) 1-100          X
## Step 3:      (P)  1-110         X           X       (S)  1-100
## Step 4:            X      (P)101            X       (S)101
##
EOF
## - MULTIREPLIC_PREPARE 4
##   dbcreate 1

$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh mumps 1

## - Step 1:
##   START INST1 INST2 RP
##   SYNC ALL_LINKS
##   Perform 100 transactions on INST1 (seqnos: 1-100).  Throughout this subtest, use simpleinstanceupdate.m described
##   above.
##   SYNC ALL_LINKS
##   $gtm_tst/com/view_instancefiles.csh -print
##   	--> The instance files should reflect the history:
## 	    INST1: <seqno= 1, name=INSTANCE1, cycle=1>
## 	    INST2: <seqno= 1, name=INSTANCE1, cycle=1>
## 	    INST3: no history
## 	    INST4: no history
## 	    INST1 will have a slot for INST2.

echo "######### STEP 1 #############"
$MSR START INST1 INST2 RP
$MSR SYNC ALL_LINKS
$MSR RUN INST1 "$gtm_tst/com/simpleinstanceupdate.csh 100"
# To avoid INSJOINED error, ensure INST3 too receive at least one update from INST1. This way the LMS Group Info fields
# get initialized to the same value for all instances. So wait for all updates from INST1 to be synced to INST3
# and then roll them back to jnl seqno 1 with a -resync rollback. The rollback will leave the LMS Group Info untouched.
$MSR START INST1 INST3 RP
$MSR SYNC ALL_LINKS
$MSR STOP INST1 INST3
$MSR RUN SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -resync=1 -losttrans=ignore.glo "*" >&! rollback_fetchresync_1.out ; $grep -E "RLBKJNSEQ|JNLSUCCESS" rollback_fetchresync_1.out'
$gtm_tst/com/view_instancefiles.csh -print -instance INST1 INST2

## - Step 2:
##   CRASH INST1
##   CRASH INST2
##   STARTSRC INST3 INST1 RP ## this should initialize the portno for the receiver on INST1
cat << EOF
##   RUN RCV=INST1 SRC=INST3 'mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=fetch.glo "*"'
##   	--> INST1 should rollback all transactions (i.e. fetch.glo should have seqno's 1-100).
EOF
##   STARTRCV INST3 INST1
##   CRASH INST1
cat << EOF
##   Perform 100 transactions on INST3 (seqnos: 1-100).
##   CRASH INST3
EOF
##   $gtm_tst/com/view_instancefiles.csh -diff
##   	--> The instance files should reflect the history:
## 	    INST1: <seqno=  1, name=INSTANCE3, cycle=1>,	state: not-crash, slot for INST2
## 	    INST2: <seqno=  1, name=INSTANCE1, cycle=1>,	state: CRASH
## 	    INST3: <seqno=  1, name=INSTANCE3, cycle=1>,	state: CRASH, slot for INST1
## 	    INST4: no history

echo "######### STEP 2 #############"
$MSR CRASH INST1
$MSR CRASH INST2
$MSR STARTSRC INST3 INST1 RP
$MSR RUN RCV=INST1 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=fetch.glo "*" >&! rollback_fetchresync_1.out ; $grep -E "RLBKJNSEQ|JNLSUCCESS" rollback_fetchresync_1.out'
$gtm_tst/com/analyze_jnl_extract.csh fetch.glo 1 100 >&! analyze_jnl_extract_fetch_glo.out
$grep PASS analyze_jnl_extract_fetch_glo.out
$MSR STARTRCV INST3 INST1
get_msrtime
$gtm_tst/com/wait_for_log.csh -log $gtm_test_msr_DBDIR1/RCVR_$time_msr.log.updproc -message "New History Content" -duration 180 -waitcreation
$MSR CRASH INST1
$MSR RUN INST3 "$gtm_tst/com/simpleinstanceupdate.csh 100"
$MSR CRASH INST3
#$gtm_tst/com/view_instancefiles.csh -diff
$gtm_tst/com/view_instancefiles.csh -print -instance INST1 INST2 INST3

## - Step 3:
cat << EOF
##   RUN INST1 'mupip_rollback.csh -losttrans=lost1.glo "*"'
## 	--> There should not be any rollback (i.e. lost1.glo should be empty)
##   START INST1 INST4 RP
##   Perform 110 transactions on INST1 (seqnos: 1-110).
##   SYNC ALL_LINKS
EOF
##   $gtm_tst/com/view_instancefiles.csh -diff
##   	--> The instance files should reflect the history:
## 	    INST1: <seqno=  1, name=INSTANCE1, cycle=2>
## 	    INST2: <seqno=  1, name=INSTANCE1, cycle=1>
## 	    INST3: <seqno=  1, name=INSTANCE3, cycle=1>
## 	    INST4: <seqno=  1, name=INSTANCE1, cycle=2>
##   CRASH INST1

echo "######### STEP 3 #############"
$MSR RUN INST1 '$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*"'
$MSR START INST1 INST4 RP
$MSR RUN INST1 "$gtm_tst/com/simpleinstanceupdate.csh 110"
$MSR SYNC ALL_LINKS
#$gtm_tst/com/view_instancefiles.csh -diff
$gtm_tst/com/view_instancefiles.csh -print
$MSR CRASH INST1

## - Step 4:
##   STOPRCV INST1 INST4
cat << EOF
##   RUN INST2 'mupip_rollback.csh -losttrans=lost2.glo "*"'
## 	--> There should not be any rollback (i.e. lost2.glo should be empty)
##   RUN RCV=INST4 SRC=INST2 'mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=fetch.glo "*"'
##   	--> INST4 should rollback to 1 since the seqno's it has are from A, but cycle=1, not cycle=2.
##   START INST2 INST4 RP
##   Perform 1 transaction on INST2 (seqno: 101).
EOF
##   SYNC INST2 INST4
##   $gtm_tst/com/view_instancefiles.csh -diff
##   	--> The instance files should reflect the history:
## 	    INST1: <seqno=  1, name=INSTANCE1, cycle=2>
## 	    INST2: <seqno=  1, name=INSTANCE1, cycle=1>
## 	           <seqno=101, name=INSTANCE2, cycle=1>
## 	    INST3: <seqno=  1, name=INSTANCE3, cycle=1>
## 	    INST4: <seqno=  1, name=INSTANCE1, cycle=1>
## 	           <seqno=101, name=INSTANCE2, cycle=1>

echo "######### STEP 4 #############"
$MSR STOPRCV INST1 INST4
$MSR RUN INST2 '$gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo "*" >&! rollback_losttrans.out ; $grep -E "RLBKJNSEQ|JNLSUCCESS" rollback_losttrans.out'
$MSR STARTSRC INST2 INST4 RP
$MSR RUN RCV=INST4 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=fetch.glo "*" >&! rollback_fetchresync_2.out ; $grep -E "RLBKJNSEQ|JNLSUCCESS" rollback_fetchresync_2.out'
$MSR RUN INST4 '$gtm_tst/com/analyze_jnl_extract.csh fetch.glo 1 110 >&! analyze_jnl_extract_fetch_glo.out ; $grep PASS analyze_jnl_extract_fetch_glo.out'
$MSR STARTRCV INST2 INST4 waitforconnect
$MSR RUN INST2 "$gtm_tst/com/simpleinstanceupdate.csh 1"
$MSR SYNC INST2 INST4
#$gtm_tst/com/view_instancefiles.csh -diff
$gtm_tst/com/view_instancefiles.csh -print


## - wrap up:
##   dbcheck -extract INST2 INST4
##

$MSR RUN INST1 '$MUPIP rundown -region "*" -override'
$MSR RUN INST3 '$MUPIP rundown -region "*" -override'
source $gtm_tst/com/dbcheck.csh -extract INST2 INST4
