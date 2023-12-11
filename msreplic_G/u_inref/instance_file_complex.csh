#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh

# Indicate to "view_instancefiles.csh/view_instancefiles.awk" to filter out "Connect Sequence Number"
# Otherwise, the reference file could have "Connect Sequence Number" values that are different in some test runs
# due to timing issues (connection between source and receiver that happens in the background could occur when
# the source side is at a non-deterministic Sequence Number). It is okay to filter out this number as the main purpose
# of this test is to verify the history records in the replication instance file.
setenv view_instancefiles_filter "Connect Sequence Number"

#=====================================================================
$echoline
cat << EOF
"Complex Example" (Section 6.1.2.2) from the design spec.

Details:
--------------
Let us take a slightly complex example to complete our understanding of the new scheme.
           |--> INST2 (B)
INST1 (A) -|
           |--> INST3 (C)

        ---------------------------------------------
               INST1/A      INST2/B      INST3/C
        ---------------------------------------------
Step 1:      (P)  1-100   (S)  1- 80   (S)  1- 70
Step 2:      (S) 71-110         X      (P) 71-120
Step 3:            X      (S) 71-140   (P)121-150

Note that in step 2, A rolls back seqnos 71-100 and in step 3, INST2 rolls back seqnos 71-80 before each starting as
secondary.  This is determined along the same lines as illustrated in Section 6.1.2.1 Simple example.
EOF

$echoline
$MULTISITE_REPLIC_PREPARE 3
# due to -different_gld option, the gld layout will be different in INST1 and [INST2 and INST3]
$gtm_tst/com/dbcreate.csh . 4 -different_gld

$echoline
echo "#- Step 1:"
$MSR START INST1 INST2 RP
$MSR START INST1 INST3 RP

#to workaround the issue:
#D9D12-002410 NOPREVLINK error in rollback if some regions were idle for the duration of EPOCH
# cut new journal files at the same time for all regions after journaling/replication was turned on at the START
# commands (or else prevlinks will be cut):
$MUPIP set $tst_jnl_str -region "*" >>&! jnl.log
$MSR RUN INST2 '$MUPIP set $tst_jnl_str -region "*"' >>&! jnl.log
$MSR RUN INST3 '$MUPIP set $tst_jnl_str -region "*"' >>&! jnl.log

echo "#  Perform 70 transactions on INST1/A (seqnos: 1-70):"
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 70'
$MSR SYNC ALL_LINKS
$gtm_tst/com/view_instancefiles.csh -print
cat << EOF
  	--> The contents should show:
	    INST1/A: <seqno= 1, name=INSTANCE1, cycle=1>
	    INST2/B: <seqno= 1, name=INSTANCE1, cycle=1>
	    INST3/C: <seqno= 1, name=INSTANCE1, cycle=1>
	    There should be slots for INST2 and INST3 on the INST1 file.
EOF
$MSR STOPSRC INST1 INST3
$gtm_tst/com/view_instancefiles.csh -diff
echo "#  	--> No difference expected"
echo "#  Perform 10 more transactions on INST1 (seqnos: 71-80)"
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR SYNC ALL_LINKS sync_to_disk
$MSR CRASH INST2
echo "#  Perform 20 more transactions on INST1 (seqnos: 80-100)"
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 20'
$gtm_tst/com/view_instancefiles.csh -diff
echo "#  	--> There should be no diff other than resync seqno fields on INST1."
$MSR CRASH INST1
$gtm_tst/com/view_instancefiles.csh -diff
echo "#  	--> There should be no diff."

$echoline
echo "#- Step 2:"
echo "# shutdown the receiver on INST3"
$MSR RUN RCV=INST3 SRC=INST1 '$MUPIP replic -receiv -shutdown -timeout=0 > SHUT_receiver.log'
$MSR REFRESHLINK INST1 INST3
setenv time_stamp `date +%H_%M_%S`
$MSR ACTIVATE INST3 INST1 RP
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
  	--> INST3 history will differ, which should reflect:
	    INST3: <seqno=  1, name=INSTANCE1, cycle=1>
                   <seqno= 71, name=INSTANCE3, cycle=1>
	    and source related fields.
EOF
echo "#  Perform 40 transactions on INST3 (seqnos: 71-110)"
$MSR RUN INST3 '$gtm_tst/com/simpleinstanceupdate.csh 40'
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
	--> No diff expected.
EOF
$MSR RUN RCV=INST1 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=fetch13.glo "*" >& rollback13.log'
$grep "JNLSUCCESS" rollback13.log
echo "#  	--> INST1 should rollback to 70 (i.e. fetch13.glo should have seqno's 71-100)."
$gtm_tst/com/analyze_jnl_extract.csh fetch13.glo 71 100
$MSR STARTRCV INST3 INST1
$MSR SYNC INST3 INST1 sync_to_disk
$MSR CRASH INST1
echo "#  Perform 10 transactions on INST3 (seqnos: 111-120)"
$MSR RUN INST3 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR CRASH INST3
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
  	--> The instance files should reflect the history:
	    INST1: <seqno=  1, name=INSTANCE1, cycle=1>	state: CRASH, slots for INST2, INST3
	           <seqno= 71, name=INSTANCE3, cycle=1>
	    INST2: <seqno=  1, name=INSTANCE1, cycle=1>	state: CRASH
	    INST3: <seqno=  1, name=INSTANCE1, cycle=1>	state: CRASH, slots for: INST1, INST2
	           <seqno= 71, name=INSTANCE3, cycle=1>
	   and Resync Sequence Number and Connect Sequence Number should be updated
EOF
echo "#- Step 3:"
$MSR RUN INST3 '$gtm_tst/com/mupip_rollback.csh -verbose -losttrans=lost1.glo "*" >& rollback3.log'
$MSR RUN INST3 '$grep JNLSUCCESS rollback3.log'
echo "#  	--> There should not be any rollback (i.e. lost1.glo should be empty)"
$MSR RUN INST3 '$gtm_tst/com/analyze_jnl_extract.csh lost1.glo 0 0'
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
  	--> There shouldn't be any diffs, except for:
	    - INST3 should not show CRASH anymore.
EOF
$MSR STARTSRC INST3 INST2 RP
$MSR RUN RCV=INST2 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=fetch23.glo "*" >& rollback23.log'
$MSR RUN INST2 '$grep JNLSUCCESS rollback23.log'
echo "#  	--> INST2 should rollback to 70 (i.e. fetch23.glo should have seqno's 71-80)."
$MSR RUN INST2 '$gtm_tst/com/analyze_jnl_extract.csh fetch23.glo 71 80'
$MSR STARTRCV INST3 INST2 waitforconnect
echo "#  Perform 20 transactions on INST3 (seqnos: 121-140)"
$MSR RUN INST3 '$gtm_tst/com/simpleinstanceupdate.csh 20'
$MSR SYNC ALL_LINKS sync_to_disk
$gtm_tst/com/view_instancefiles.csh -diff -printhistory
cat << EOF
	--> The instance files should reflect the history:
	    INST1: <seqno=  1, name=INSTANCE1, cycle=1>
	           <seqno= 71, name=INSTANCE3, cycle=1>
	    INST2: <seqno=  1, name=INSTANCE1, cycle=1>
	           <seqno= 71, name=INSTANCE3, cycle=1>
	           <seqno=121, name=INSTANCE3, cycle=2>
	    INST3: <seqno=  1, name=INSTANCE1, cycle=1>
	           <seqno= 71, name=INSTANCE3, cycle=1>
	           <seqno=121, name=INSTANCE3, cycle=2>
EOF
$MSR CRASH INST2
echo "#  Perform 10 transactions on INST3 (seqnos: 141-150)"
$MSR RUN INST3 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR CRASH INST3
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
	--> The instance files should reflect the history:
	    INST1: <seqno=  1, name=INSTANCE1, cycle=1>
	           <seqno= 71, name=INSTANCE3, cycle=1>
	    INST2: <seqno=  1, name=INSTANCE1, cycle=1>
	           <seqno= 71, name=INSTANCE3, cycle=1>
	           <seqno=121, name=INSTANCE3, cycle=2>
	    INST3: <seqno=  1, name=INSTANCE1, cycle=1>
	           <seqno= 71, name=INSTANCE3, cycle=1>
	           <seqno=121, name=INSTANCE3, cycle=2>
	    i.e. no diff in history from the last time.
EOF
# the echo of the null string is a workaround for the MSR framework so that there is no input redirection
# on the last command (the framework appends </dev/null after the MSR command in the execute file).
$MSR RUN INST3 '$MUPIP rundown -reg "*" -override |& sort ; echo ""' 	# we are not going to use INST3 from now on, so rundown

$echoline
echo "#- Step 4:"
$MSR RUN INST2 '$gtm_tst/com/mupip_rollback.csh -verbose -losttrans=lost2.glo "*" >& rollback2.log'
$MSR RUN INST2 '$grep JNLSUCCESS rollback2.log'
echo "# 	--> There should not be any rollback (i.e. lost2.glo should be empty)"
$MSR RUN INST2 '$gtm_tst/com/analyze_jnl_extract.csh lost2.glo 0 0'
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
	--> There should not be any diff other than cleaned up fields on INST2
	    (due to rollback) and cleared fields INST3 (due to rundown)."
EOF
$MSR STARTSRC INST2 INST1 RP
echo "#  Make an update on INST2"
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 1'
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
  	--> INST2 instance will have the history:
	    INST2: <seqno=  1, name=INSTANCE1, cycle=1>
	           <seqno= 71, name=INSTANCE3, cycle=1>
	           <seqno=121, name=INSTANCE3, cycle=2>
	           <seqno=141, name=INSTANCE2, cycle=1>
EOF
$MSR RUN RCV=INST1 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=fetch12.glo "*" >& rollback12.log'
$grep JNLSUCCESS rollback12.log
echo "#  	--> INST1 should not do any rollback, i.e. there should be no lost transactions (fetch12.glo should be empty)."
$MSR RUN INST1 '$gtm_tst/com/analyze_jnl_extract.csh fetch12.glo 0 0'
$MSR STARTRCV INST2 INST1
$MSR SYNC INST2 INST1
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
  	--> The instance files should reflect the history:
	    INST1: <seqno=  1, name=INSTANCE1, cycle=1>
	           <seqno= 71, name=INSTANCE3, cycle=1>
	           <seqno=121, name=INSTANCE3, cycle=2>	# note this is received from INST2 actually
	           <seqno=141, name=INSTANCE2, cycle=1>
EOF
echo "#- wrap up:"
$gtm_tst/com/dbcheck.csh -extract INST1 INST2
#=====================================================================
