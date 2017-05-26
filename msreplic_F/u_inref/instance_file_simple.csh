#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#=====================================================================
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
$echoline
cat << EOF
"Simple Example" (Section 6.1.2.1) from the design spec.

Details:
--------------
Let us take a simple example of three instances A, B, C with the following sequence of events. The symbol (P) below
denotes that instance was primary in that step.  The symbol (S) below denotes that instance was a secondary in that
step.  The symbol X below denotes that instance crashed in that step.  The notation 1-100 below implies the seqno
range from 1 to 100 both inclusive.
           |--> INST2 (B)
INST1 (A) -|
           |--> INST3 (C)

        ---------------------------------------------
                 INST1/A     INST2/B     INST3/C
        ---------------------------------------------
Step 1:        (P) 1-100   (S) 1-80    (S)  1-70
Step 2:             X           X      (P) 71-120
EOF
$echoline

$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh .

$echoline
echo "#- Step 1:"
$MSR START INST1 INST2 RP
$MSR START INST1 INST3 RP
echo "#  Perform 70 transactions on INST1/A (seqnos: 1-70):"
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 70'
$MSR SYNC ALL_LINKS
$gtm_tst/com/view_instancefiles.csh -print	# no.1
cat << EOF
  	--> The contents should show:
	    INST1/A: <seqno= 1, name=INSTANCE1, cycle=1>	state: CRASH
	    INST2/B: <seqno= 1, name=INSTANCE1, cycle=1>	state: CRASH
	    INST3/C: <seqno= 1, name=INSTANCE1, cycle=1>	state: CRASH
EOF
$MSR STOPSRC INST1 INST3
echo "#  Perform 10 more transactions on INST1/A (seqnos: 70-80):"
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR SYNC ALL_LINKS sync_to_disk
$MSR CRASH INST2
echo "#  Perform 20 more transactions on INST1/A (seqnos: 80-100):"
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 20'
$gtm_tst/com/view_instancefiles.csh -diff	#no.2
$MSR CRASH INST1
echo "# shutdown the receiver on INST3"
$MSR RUN RCV=INST3 SRC=INST1 '$MUPIP replic -receiv -shutdown -timeout=0 > SHUT_receiver.log'
$MSR REFRESHLINK INST1 INST3

$echoline
echo "#- Step 2:"
setenv time_stamp `date +%H_%M_%S`
$MSR ACTIVATE INST3 INST1 RP
$gtm_tst/com/view_instancefiles.csh -diff	#no.3
cat << EOF
  	--> The following history of triples should be stored in the respective instances.
	    INST1/A: <no diff>
	    INST2/B: <no diff>
	    INST3/C: <seqno= 1, name=INSTANCE1, cycle=1>	state: CRASH
	             <seqno=71, name=INSTANCE3, cycle=1>
	    i.e. INST3 is now RP, so has the related fields initialized, and a new history record.
EOF
echo "#  Perform 50 updates on INST3/C (seqnos: 71-120):"
$MSR RUN INST3 '$gtm_tst/com/simpleinstanceupdate.csh 50'
$gtm_tst/com/view_instancefiles.csh -diff	#no.4

$echoline
echo "#- Step 3:"
echo "#  Start replicating on INST1 and INST2 from INST3:"
$MSR RUN RCV=INST1 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=fetch13.glo "*" >& rollback13.log'
# Check that the instance rolls back to seqno 71. Searching for RLBKJNSEQ does that.
# While at that, search for a few other deterministic messages from rollback that indicate successful execution of various stages.
$grep -E "MUJNLSTAT|RESOLVESEQNO|FILERENAME|FILECREATE|RLBKJNSEQ|RLBKSTRMSEQ|JNLSUCCESS" rollback13.log
echo "#  	--> INST1 should rollback to 71 (i.e. fetch13.glo should have seqno's 71-100)."
$gtm_tst/com/analyze_jnl_extract.csh fetch13.glo 71 100
$gtm_tst/com/view_instancefiles.csh -diff	#no.5
echo "#  	--> There should not be any diff other than CRASH related fileheader fields that would be cleared on INST1."
$MSR STARTRCV INST3 INST1
$MSR SYNC INST3 INST1
$gtm_tst/com/view_instancefiles.csh -diff	#no.6
cat << EOF
  	--> INST1 will differ (source related fields cleared due to rollback), history should reflect:
	    INST1/A: <seqno= 1, name=INSTANCE1, cycle=1>
	             <seqno=71, name=INSTANCE3, cycle=1>
EOF
$MSR STARTSRC INST3 INST2 RP
$MSR RUN RCV=INST2 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -fetchresync=__RCV_PORTNO__ -losttrans=fetch23.glo "*" >& rollback23.tmp; $grep "%GTM-" rollback23.tmp'
echo "#  	--> INST2 should rollback to 70 (i.e. fetch23.glo should have seqno's 71-80)."
$MSR RUN INST2 '$gtm_tst/com/analyze_jnl_extract.csh fetch23.glo 71 80'
$gtm_tst/com/view_instancefiles.csh -diff	#no.7
cat << EOF
  	--> There should not be any diff other than CRASH related fileheader fields that would be cleared on INST2,
	    and a new slot for INST2 on INST3.
EOF
$MSR STARTRCV INST3 INST2
$MSR SYNC ALL_LINKS
$gtm_tst/com/view_instancefiles.csh -diff	#no.8
cat << EOF
  	--> INST2 is now up, so some fields will be initialized.
	    INST2 history will differ, which should reflect:
	    INST2/B: <seqno= 1, name=INSTANCE1, cycle=1>
	             <seqno=71, name=INSTANCE3, cycle=1>
EOF
echo "#- Wrap up:"
$MSR STOP ALL_LINKS
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3
$gtm_tst/com/view_instancefiles.csh -print	#no.9
#=====================================================================
