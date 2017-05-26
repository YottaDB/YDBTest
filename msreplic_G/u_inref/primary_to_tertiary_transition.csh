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

## ## multisite_replic/primary_to_tertiary_transition		###1###Kishore
cat << EOF
## This is to test the transitions of primary to be a tertiary (i.e. secondary to a propagating primary), which is not
## allowed.
## INST1 --> INST2 --> INST3
##
EOF
## - $MULTISITE_REPLIC_PREPARE 3
##   dbcreate 1

$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh mumps 1

## - $MSR START INST1 INST2
##   $MSR START INST2 INST3 PP
##   Some updates on INST1:
##   RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 1'
##   $MSR SYNC ALL_LINKS
##   CRASH INST1

$MSR START INST1 INST2
$MSR START INST2 INST3 PP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 1'
$MSR SYNC ALL_LINKS sync_to_disk
$MSR CRASH INST1

## - Attempt to do fetchresync rollback on INST1 from INST3:
##   $MSR STARTSRC INST3 INST1 PP
##   $MSR RUN RCV=INST1 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost1.glo "*"'
##   	--> We expect a PRIMARYNOTROOT error from the rollback. We expect the source server on INST3 to notice the
## 	    connection getting closed but should still be alive.
##   $MSR REFRESHLINK INST3 INST1 # to update framework files
## - Instead, rollback to the correct instance:
##   $MSR STOPSRC INST2 INST3
##   $MSR RUN RCV=INST2 SRC=INST1 '$MUPIP replic -receiv -shutdown -timeout=0'
##   $MSR ACTIVATE INST2 INST1 RP
##   $MSR RUN RCV=INST1 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost2.glo "*"'
##   	--> This should succeed, and lost2.glo should not have any transactions.

$MSR STARTSRC INST3 INST1 PP
# In order to avoid ASSERT failure due to abrupt exit of muip recover, define the below white-box test scenario
# Below backward rollback invocation is expected to fail. Therefore pass "-backward" explicitly to mupip_rollback.csh
# (and avoid implicit "-forward" rollback invocation that would otherwise happen by default.
$MSR RUN RCV=INST1 SRC=INST3 'set msr_dont_chk_stat ; $gtm_tst/com/mupip_rollback.csh -backward -fetchresync=__RCV_PORTNO__ -losttrans=lost1.glo "*" >&! rollback_inst1inst3.out'
$msr_err_chk $gtm_test_msr_DBDIR1/rollback_inst1inst3.out PRIMARYNOTROOT MUNOACTION
$MSR STOPSRC INST3 INST1
$MSR REFRESHLINK INST3 INST1
$MSR STOPSRC INST2 INST3
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP replic -receiv -shutdown -timeout=0 >&! receiv_shut_INST1INST2.out'
$MSR REFRESHLINK INST1 INST2
$MSR ACTIVATE INST2 INST1 RP
$MSR RUN RCV=INST1 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost2.glo "*" >&! rollback_inst1inst2.out'
$grep "Rollback successful" $gtm_test_msr_DBDIR1/rollback_inst1inst2.out
$gtm_tst/com/analyze_jnl_extract.csh lost2.glo 0 0
$MSR STOPSRC INST2 INST1

cat << EOF
## - Attempt to start replication from INST3 to INST1:
##   \$MSR START INST3 INST1
## 	--> We expect a PRIMARYNOTROOT from the receiver server on INST1. The source server on INST3 should notice the
## 	    connection getting closed but should still be alive.
EOF
## 	    Due to all the errors, it might be better to implement this in sections, i.e. call STARTSRC and STARTRCV
## 	    separately (or even the actual MUPIP commands).
cat << EOF
##   \$MSR START INST2 INST1
##   	--> This should succeed.
## - Try to move INST1 to tertiary, it should still issue PRIMARYNOTROOT (since -losttncomplete was not run yet).
##   \$MSR STOP INST2 INST1
##   \$MSR START INST3 INST1
## 	--> We expect a PRIMARYNOTROOT from the receiver server on INST1, since -losttncomplete was not run yet. The
## 	    source server on INST3 should notice the connection getting closed but should still be alive.
EOF
$MSR STARTSRC INST3 INST1 PP
# We expect the receiver server to exit with a PRIMARYNOTROOT error. The $MSR STARTRCV done below will actually invoke
# a framework script RCVR.csh which in turn starts the receiver server and then does a checkhealth to ensure it is up
# and running. It is possible in rare cases that the receiver server gets the PRIMARYNOTROOT error and exits (thereby
# cleaning up the receive pool) even before the checkhealth is attempted in RCVR.csh. In this case, the checkhealth will
# error out with GTM-E-NORECVPOOL message. We do not want this to happen so we specifically ask RCVR.csh to skip the
# checkhealth by setting the environment variable gtm_test_repl_skiprcvrchkhlth. It is unset right afterwards.
setenv gtm_test_repl_skiprcvrchkhlth 1
$MSR STARTRCV INST3 INST1
unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$gtm_tst/com/wait_for_log.csh -log $gtm_test_msr_DBDIR1/RCVR_$time_msr.log -message "Receiver server exiting" -duration 180 -waitcreation
$msr_err_chk $gtm_test_msr_DBDIR1/RCVR_$time_msr.log PRIMARYNOTROOT
$MSR STOPSRC INST3 INST1
$MSR RUN RCV=INST1 SRC=INST3 '$MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__  >&! passivesrc_shut_INST3INST1_1.out'
# The above is done because, the receiver will be shut down but the passive server will be alive still.
# The next STARTRCV will complain.
$MSR REFRESHLINK INST3 INST1
$MSR STARTSRC INST2 INST1
$MSR STARTRCV INST2 INST1
$MSR SYNC INST2 INST1
$MSR STOP INST2 INST1
$MSR STARTSRC INST3 INST1 PP
# We expect the receiver server to exit with a PRIMARYNOTROOT error. The $MSR STARTRCV done below will actually invoke
# a framework script RCVR.csh which in turn starts the receiver server and then does a checkhealth to ensure it is up
# and running. It is possible in rare cases that the receiver server gets the PRIMARYNOTROOT error and exits (thereby
# cleaning up the receive pool) even before the checkhealth is attempted in RCVR.csh. In this case, the checkhealth will
# error out with GTM-E-NORECVPOOL message. We do not want this to happen so we specifically ask RCVR.csh to skip the
# checkhealth by setting the environment variable gtm_test_repl_skiprcvrchkhlth. It is unset right afterwards.
setenv gtm_test_repl_skiprcvrchkhlth 1
$MSR STARTRCV INST3 INST1
unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$gtm_tst/com/wait_for_log.csh -log $gtm_test_msr_DBDIR1/RCVR_$time_msr.log -message "Receiver server exiting" -duration 120 -waitcreation
$msr_err_chk $gtm_test_msr_DBDIR1/RCVR_$time_msr.log PRIMARYNOTROOT
$MSR RUN RCV=INST1 SRC=INST3 '$MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__  >&! passivesrc_shut_INST3INST1_2.out'
$MSR REFRESHLINK INST3 INST1
$MSR STOPSRC INST3 INST1

cat << EOF
## - Run -losttncomplete.
## - Now move INST1 to tertiary, it should succeed.
EOF

$MSR START INST2 INST1
$MSR RUN INST2 '$MUPIP replic -source -losttncomplete >& p2ttsn.tmp; cat p2ttsn.tmp'
$MSR RUN INST1 '$MUPIP replic -source -losttncomplete'
$MSR STOP INST2 INST1
$MSR STARTSRC INST3 INST1 PP

##   $MSR RUN RCV=INST1 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost3.glo "*"'
##   	--> This should succed, with an empty lost3.glo (there should not be any lost transactions at this point).
##   Check lost3.glo is empty:
##   $gtm_tst/com/analyze_jnl_extract.csh lost3.glo 0 0
##   $MSR START INST3 INST1
##   	--> This should succeed since INST1 has already come up as a secondary of a root primary.

$MSR RUN RCV=INST1 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=lost3.glo "*" >&! rollback_fetchresync_1.out'
$MSR RUN INST1 '$grep -E "RLBKJNSEQ|JNLSUCCESS" rollback_fetchresync_1.out'
$gtm_tst/com/analyze_jnl_extract.csh lost3.glo 0 0
$MSR STARTRCV INST3 INST1

## - Wrap up:
##   RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 1'
##   dbcheck.csh -extract INST1 INST2 INST3
$MSR STARTSRC INST2 INST3
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 1'
$gtm_tst/com/dbcheck.csh -extract
