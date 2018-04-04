#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
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
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh

cat << EOF
=====================================================================
## multisite_replic/instance_file_flipflop
One last complex example on instance file histories. Let's see if an instance can catch up complicated histories, and
if undoing complicated histories work.

        -----------------------------------------------------------------
               INST1/A            INST2/B          INST3/C      INST4/D
        -----------------------------------------------------------------
Step  1:     (P)  1- 60         (S)  1- 60       (S)  1- 50   (S)  1-55
	           X                  -                -            -
Step  2:     (S) 61- 80         (P) 61- 80             |            |
Step  3:     (P) 81- 90         (S) 81- 90             |            |
Step  4:     (S) 91-110         (P) 91-110             |            |
Step  5:     (P)111-120-130-140 (S)111-140             |            |		#i.e. stop-start INST1 multiple times
Step  6:     (S)141-180         (P)141-150-160-170-180 |            |		#i.e. stop-start INST2 multiple times
Step  7:     (S)181-190         (P)181-210       (S) 51-200         |
Step  8:           -                  -                -      (P)56-100
Step  9:     (S) 56-100         (S) 56-100       (S) 56-100

X denotes crash
- denotes graceful shutdown
| denotes status quo
If nothing is specified from one line to the next, and P becomes S, that means there was a shutdown in between (not a
crash).
=====================================================================
EOF

$echoline
echo "#- Step 1:"
echo "# Setup an external filter for the replication servers"
echo "# This will make every source server in this test use the external filter."
source $gtm_tst/com/random_extfilter.csh	# sets gtm_tst_ext_filter_src and gtm_tst_ext_filter_rcvr env vars
# Do the above BEFORE MULTISITE_REPLIC_PREPARE that way these env vars are automatically transported to the remote sites
# in case of a -multisite (i.e. multi-host) run.

$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh .
$echoline
$echoline
echo "#- Step 2:"
$MSR START INST1 INST2	## RP deliberately omitted in this test, should default correctly
$MSR START INST1 INST3
$MSR START INST1 INST4
echo "# Perform 50 transactions on INST1 (seqnos: 1-50)."
$gtm_tst/com/simpleinstanceupdate.csh 50
$MSR SYNC ALL_LINKS
$MSR STOP INST1 INST3
echo "# Perform  5 transactions on INST1 (seqnos: 51-55)."
$gtm_tst/com/simpleinstanceupdate.csh 5
$MSR SYNC ALL_LINKS
$MSR STOP INST1 INST4
echo "# Perform  5 transactions on INST1 (seqnos: 56-60)."
$gtm_tst/com/simpleinstanceupdate.csh 5
$MSR SYNC INST1 INST2 sync_to_disk
echo "#Crash INST1"
$MSR CRASH INST1
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP replic -receiv -shutdown -timeout=0 > SHUT_receiver1.log'
$gtm_tst/com/view_instancefiles.csh -print
cat << EOF
	--> The instance files should reflect the history:
	    INST1/A: <seqno= 1, name=INSTANCE1, cycle=1>, state=CRASH, slots for all instances
	    INST2/B: <seqno= 1, name=INSTANCE1, cycle=1>, state=CRASH
	    INST3/C: <seqno= 1, name=INSTANCE1, cycle=1>
	    INST4/D: <seqno= 1, name=INSTANCE1, cycle=1>
EOF

$echoline
echo "#- Step 3:"
$MSR ACTIVATE INST2 INST1 RP
$MSR RUN INST1 '$MUPIP rundown -reg "*" -override'
$MSR REFRESHLINK INST1 INST2
setenv time_stamp `date +%H_%M_%S`
$MSR RUN RCV=INST1 SRC=INST2 'set msr_dont_chk_stat; set msr_dont_trace; set echo; $MUPIP replic -source -start -buffsize=$tst_buffsize -passive -log=passive1.log -instsecondary=__SRC_INSTNAME__' >& log1.log
echo "#  	--> We expect a REPLREQROLLBACK error since INST1 has crashed, but has not run a rollback since."
$gtm_tst/com/check_error_exist.csh log1.log REPLREQROLLBACK GTM-I-TEXT
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out REPLREQROLLBACK GTM-I-TEXT > /dev/null
echo "log1.log:"; cat log1.log
$MSR RUN RCV=INST1 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=fetch12.glo "*"' >& rollback12.log
$grep JNLSUCCESS rollback12.log
echo "#  	--> INST1 should rollback to 61 (i.e. verify that fetch12.glo is empty)."
$gtm_tst/com/analyze_jnl_extract.csh fetch12.glo 0 0
$MSR STARTRCV INST2 INST1 waitforconnect
echo "#  Perform 20 transactions on INST2 (seqnos: 61-80)."
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 20'
$MSR SYNC INST2 INST1
$MSR STOP INST2 INST1
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
  	--> The changed instance files should reflect the history (INST3 and INST4 will not change for a while, so I
	    will not list them here):
	    INST1/A: <seqno= 1, name=INSTANCE1, cycle=1>
	             <seqno=61, name=INSTANCE2, cycle=1>
	    INST2/A: <seqno= 1, name=INSTANCE1, cycle=1>
	             <seqno=61, name=INSTANCE2, cycle=1>
EOF

$MSR START INST1 INST2
echo "#  Perform 10 transactions on INST1 (seqnos: 81-90)."
$gtm_tst/com/simpleinstanceupdate.csh 10
$MSR SYNC ALL_LINKS
$MSR STOP INST1 INST2
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
  	--> Both INST1 and INST2 instance files should reflect the history:
	    <seqno=  1, name=INSTANCE1, cycle=1>
	    <seqno= 61, name=INSTANCE2, cycle=1>
	    <seqno= 81, name=INSTANCE1, cycle=2>
EOF

$echoline
echo "# - Step 4:"
$MSR START INST2 INST1
echo "#  Perform 20 transactions on INST2 (seqnos: 91-110)."
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 20'
$MSR SYNC ALL_LINKS
$MSR STOP INST2 INST1
  $gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
  	--> Both INST1 and INST2 instance files should reflect the history:
	    <seqno=  1, name=INSTANCE1, cycle=1>
	    <seqno= 61, name=INSTANCE2, cycle=1>
	    <seqno= 81, name=INSTANCE1, cycle=2>
	    <seqno= 91, name=INSTANCE2, cycle=2>
EOF

$echoline
echo "#- Step 5:"
$MSR START INST1 INST2
echo "# Start update process helpers on the secondary, INST2:"
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP  replicate -receive -start -helpers >& helpers_start.out'
echo "#  Perform 10 transactions on INST1 (seqnos: 111-120)."
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
echo "#  Perform 10 transactions on INST1 (seqnos: 121-130)."
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2
# wait for connection to replication server to occur prior to doing primary updates for accurate Connect Sequence Number"
get_msrtime
$gtm_tst/com/wait_for_log.csh -log SRC_$time_msr.log -message "Sending REPL_HISTREC message" -duration 100 -waitcreation  # wait up to 100 seconds
echo "#  Perform 10 transactions on INST1 (seqnos: 131-140)."
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR SYNC INST1 INST2 # note that we do not necessarily sync above, this should sync all.
$MSR STOPSRC INST1 INST2
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
  	--> Both INST1 and INST2 instance files should reflect the history:
	    <seqno=  1, name=INSTANCE1, cycle=1>
	    <seqno= 61, name=INSTANCE2, cycle=1>
	    <seqno= 81, name=INSTANCE1, cycle=2>
	    <seqno= 91, name=INSTANCE2, cycle=2>
	    <seqno=111, name=INSTANCE1, cycle=3>
	    <seqno=121, name=INSTANCE1, cycle=4>
	    <seqno=131, name=INSTANCE1, cycle=5>
	    INST2 will show state CRASH (since the passive source server is alive)
EOF

$echoline
echo "#- Step 6:"
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP replic -receiv -shutdown -timeout=0 > SHUT_receiver2.log'
setenv time_stamp `date +%H_%M_%S`
$MSR ACTIVATE INST2 INST1 RP
$MSR REFRESHLINK INST1 INST2
$MSR STARTRCV INST2 INST1
echo "#  Perform 10 transactions on INST2 (seqnos: 141-150)"
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR STOPSRC INST2 INST1
$MSR STARTSRC INST2 INST1
echo "#  Perform 10 transactions on INST2 (seqnos: 151-160)"
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR STOPSRC INST2 INST1
$MSR STARTSRC INST2 INST1
echo "#  Perform 10 transactions on INST2 (seqnos: 161-170)"
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR STOPSRC INST2 INST1
$MSR STARTSRC INST2 INST1
# wait for connection to replication server to occur prior to doing primary updates for accurate Connect Sequence Number"
get_msrtime
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log 'SRC_$time_msr.log' -message "Sending REPL_HISTREC message" -duration 100 -waitcreation'
echo "#  Perform 10 transactions on INST2 (seqnos: 171-180)"
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR SYNC INST2 INST1 #note that we do not necessarily sync above, this should sync all.
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
  	--> Both INST1 and INST2 instance files should reflect the history:
	    <seqno=  1, name=INSTANCE1, cycle=1>
	    <seqno= 61, name=INSTANCE2, cycle=1>
	    <seqno= 81, name=INSTANCE1, cycle=2>
	    <seqno= 91, name=INSTANCE2, cycle=2>
	    <seqno=111, name=INSTANCE1, cycle=3>
	    <seqno=121, name=INSTANCE1, cycle=4>
	    <seqno=131, name=INSTANCE1, cycle=5>
	    <seqno=141, name=INSTANCE2, cycle=3>
	    <seqno=151, name=INSTANCE2, cycle=4>
	    <seqno=161, name=INSTANCE2, cycle=5>
	    <seqno=171, name=INSTANCE2, cycle=6>
	    And they will both show CRASH (since they are both up)
EOF

$echoline
echo "#- Step 7:"
$MSR START INST2 INST3
echo "# Perform 10 transactions on INST2 (seqnos: 181-190)"
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR SYNC INST2 INST1
$MSR STOPRCV INST2 INST1
echo "#  Perform 10 transactions on INST2 (seqnos: 191-200)"
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR SYNC INST2 INST3
$MSR STOPRCV INST2 INST3
echo "#  Perform 10 transactions on INST2 (seqnos: 201-210)"
$MSR RUN INST2 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$gtm_tst/com/view_instancefiles.csh -diff -printhistory
cat << EOF
  	--> INST1 and INST2 should not change (other than the slot on INST2 for INST3).
	    INST3 will now get the complete history, although it will receive all of these transactions from INST2:
	    <seqno=  1, name=INSTANCE1, cycle=1>
	    <seqno= 61, name=INSTANCE2, cycle=1>
	    <seqno= 81, name=INSTANCE1, cycle=2>
	    <seqno= 91, name=INSTANCE2, cycle=2>
	    <seqno=111, name=INSTANCE1, cycle=3>
	    <seqno=121, name=INSTANCE1, cycle=4>
	    <seqno=131, name=INSTANCE1, cycle=5>
	    <seqno=141, name=INSTANCE2, cycle=3>
	    <seqno=151, name=INSTANCE2, cycle=4>
	    <seqno=161, name=INSTANCE2, cycle=5>
	    <seqno=171, name=INSTANCE2, cycle=6>
	    INST2 will show CRASH state as its still alive.
  Since this is probably the most interesting instance file (in terms of history) in the test system, let's print one
  of these files (the history content) to verify how long histories are printed.
EOF

$echoline
echo "#- Step 8:"
$MSR STOP INST2
$MSR STARTSRC INST4 INST1
echo "#  Perform 45 transactions on INST4 (seqnos: 56-100)"
$MSR RUN INST4 '$gtm_tst/com/simpleinstanceupdate.csh 45'
$gtm_tst/com/view_instancefiles.csh -diff -ignore '0: Journal Sequence Number'
cat << EOF
	--> The history will not change for INST1, INST2, INST3.
	    No diff for INST1, and INST3
	    The INST4 instance file should show:
	    <seqno=  1, name=INSTANCE1, cycle=1>, state=CRASH, slot for INST1
	    <seqno= 56, name=INSTANCE4, cycle=1>
EOF

$echoline
echo "#- Step 9:"
echo "#  INST1, INST2, and INST3 will have to rollback all the way to 56, and their histories should shrink."
$MSR STARTSRC INST4 INST2
$MSR STARTSRC INST4 INST3
# We expect the receiver server to exit as in this case the secondary will be ahead of primary and give REPL_ROLLBACK_FIRST.
# The $MSR STARTRCV done below will actually invoke a framework script RCVR.csh which in turn starts the receiver server
# and then does a checkhealth to ensure it is up and running. It is possible in rare cases that the receiver server
# exits (thereby cleaning up the receive pool) even before the checkhealth is attempted in RCVR.csh. In this case,
# the checkhealth will error out with YDB-E-NORECVPOOL message. We do not want this to happen so we specifically ask RCVR.csh
# to skip the checkhealth by setting the environment variable gtm_test_repl_skiprcvrchkhlth. It is unset right afterwards.
setenv gtm_test_repl_skiprcvrchkhlth 1
$MSR STARTRCV INST4 INST1
unsetenv gtm_test_repl_skiprcvrchkhlth
echo "#  	--> The receiver server will issue the error: Received REPL_ROLLBACK_FIRST message. Secondary ahead of primary."
get_msrtime	# sets $time_msr
$gtm_tst/com/wait_for_log.csh -log RCVR_$time_msr.log -message "Received REPL_ROLLBACK_FIRST message" -duration 100 -grep	# wait upto 100 seconds
$MSR RUN INST1 'set msr_dont_trace ; $gtm_tst/com/wait_until_srvr_exit.csh rcvr'
$MSR RUN RCV=INST1 SRC=INST4 '$MUPIP replic -source -instsecondary=__SRC_INSTNAME__ -shutdown -timeout=0 > SHUT_passivesource.log' # shutdown the passive source server
$MSR REFRESHLINK INST4 INST1
$MSR RUN RCV=INST1 SRC=INST4 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=fetch14.glo "*" >& rollback14.log'
$grep JNLSUCCESS rollback14.log
$MSR RUN RCV=INST2 SRC=INST4 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=fetch24.glo "*" >& rollback24.log'
$MSR RUN INST2 '$grep JNLSUCCESS rollback24.log'
$MSR RUN RCV=INST3 SRC=INST4 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=fetch34.glo "*" >& rollback34.log'
$MSR RUN INST3 '$grep JNLSUCCESS rollback34.log'
$MSR RUN INST1 '$gtm_tst/com/analyze_jnl_extract.csh fetch14.glo 56 190'
$MSR RUN INST2 '$gtm_tst/com/analyze_jnl_extract.csh fetch24.glo 56 210'
$MSR RUN INST3 '$gtm_tst/com/analyze_jnl_extract.csh fetch34.glo 56 200'
cat << EOF
  	--> All three will rollback seqnos 56 and later, i.e. fetch{1,2,3}.glo should have these transactions.
	    We do not need to check the lost transaction files very detailed (since there is a lost_trans test), but
	    let's check they contain the seqnos 56 and later.
EOF
$gtm_tst/com/view_instancefiles.csh -diff -ignore '0: Journal Sequence Number'
cat << EOF
  	--> INST1, INST2, INST3 should have removed transactions after 55:
	    <seqno=  1, name=INSTANCE1, cycle=1>
	    INST4:
	    <seqno=  1, name=INSTANCE1, cycle=1>, state=CRASH, slots for INST1, INST2, INST3
	    <seqno= 56, name=INSTANCE4, cycle=1>
EOF
$MSR STARTRCV INST4 INST1
$MSR STARTRCV INST4 INST2
$MSR STARTRCV INST4 INST3
$MSR SYNC ALL_LINKS
$MSR STOP ALL_LINKS
$gtm_tst/com/view_instancefiles.csh -diff -ignore '0: Journal Sequence Number'
cat << EOF
	--> The histories should all show (none in CRASH state).
	    <seqno=  1, name=INSTANCE1, cycle=1>
	    <seqno= 56, name=INSTANCE4, cycle=1>
EOF
echo "#- wrap up:"
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3 INST4
#=====================================================================
