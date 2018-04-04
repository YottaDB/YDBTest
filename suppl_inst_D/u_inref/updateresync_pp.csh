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

# 36) Test of -updateresync on a supplementary propagating primary instance.
#         Start A->P replication. Do 10 updates on A and 10 updates on P. P now has 20 updates.
#         Now take a backup of P (instance file, db files) and restore them on Q.
#         Now do 10 more updates on A and 10 more updates on P. P now has 40 updates.
#         Start P->Q replication with -updateresync usage when receiver starts up on Q.
#         Use the instance file from the P backup when using -updateresync on Q.
#         Things should start off fine.
#         Q should start accepting seqnos from 21 thru 40.
#         In the instance file of Q, one should see a strm_index=0 history record written first which should be identical to
#         the FIRST history record written on P. In addition, we should see a strm_index=1 history record in Q which should
#         be identical to the history record on P that was obtained from A. The strm_seqno of A's history record on Q should be 11
#         whereas it would 1 on P. Similarly, the strm_seqno of P's history record on Q should be 11 whereas it would be 1 on P.
#         Now bring P down completely (note Q is still up but waiting for a connection with P).
#         Do 10 more updates on A.
#         Bring P up.
#         Do 10 local updates on P.
#         Now bring up the source server on P (for P->Q replication).
#         The remaining 20 updates should just stream across without issues.
#
# A -> P : INST1 -> INST2
# P -> Q : INST2 -> INST3
#
# The test copied database files from one instance to another. This leads to "%YDB-E-CRYPTKEYFETCHFAILED, Cannot obtain encryption key" error.
setenv test_encryption "NON_ENCRYPT" # Since database file is moved from INST2 to INST3
# Since this test moves backup from P to Q, it is possible to have mixture of V4 and V5 format blocks on Q which will cause SSV4NOALLOW integ error.
# So disable the random setting of mupip_set_version
setenv gtm_test_mupip_set_version "disable"
$MULTISITE_REPLIC_PREPARE 1 2
$gtm_tst/com/dbcreate.csh mumps 1

echo "# Start A->P replication and do 10 updates each on A and P"
setenv test_replic_suppl_type 1
$MSR START INST1 INST2 RP
get_msrtime
# Since the test relies on sequence numbers, make sure the connection is established before doing updates
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log RCVR_'${time_msr}'.log -message "New History Content"'
$MSR RUN INST1 '$gtm_dist/mumps -run %XCMD "for i=1:1:10 set ^INST1(i)=i"'
$MSR RUN INST2 '$gtm_dist/mumps -run %XCMD "for i=1:1:10 set ^INST2(i)=i"'
$MSR SYNC ALL_LINKS

echo "# Take backup of P and restore on Q. Do 10 more updates on A and P"
$MSR RUN INST2 'mkdir bak_20 ; $MUPIP backup -replinstance=bak_20 "*" bak_20' >&! backup_inst2.out
$MSR RUN SRC=INST2 RCV=INST3 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/bak_20/*.{dat,repl} _REMOTEINFO___RCV_DIR__/'
$MSR RUN INST1 '$gtm_dist/mumps -run %XCMD "for i=11:1:20 set ^INST1(i)=i"'
$MSR RUN INST2 '$gtm_dist/mumps -run %XCMD "for i=11:1:20 set ^INST2(i)=i"'

echo "# Start P->Q replication with -updatreresync=<backupfromP.repl>"
$MSR RUN INST3 "set msr_dont_trace; mv mumps.repl inst2.repl ; $MUPIP replic -instance_create -name=$gtm_test_msr_INSTNAME3 -supplementary $gtm_test_qdbrundown_parms"
setenv test_replic_suppl_type 2
# signal jnl_on.csh to use -file while turning on journaling, as the db copied from INST2 will have jnl file pointing INST2
setenv test_jnl_on_file 1
$MSR STARTSRC INST2 INST3
$MSR STARTRCV INST2 INST3 updateresync=inst2.repl
unsetenv test_jnl_on_file
$MSR SYNC ALL_LINKS

echo "# The history records of INST2 and INST3 should be identical, but for the sequence numbers"
$MSR RUN INST2 '$MUPIP replic -editinstance -show mumps.repl '>&! inst2_showinstance.out
$MSR RUN INST3 '$MUPIP replic -editinstance -show mumps.repl '>&! inst3_showinstance.out
$grep "HST #" inst2_showinstance.out >&! inst2_hist.out
$grep "HST #" inst3_showinstance.out >&! inst3_hist.out
diff inst2_hist.out inst3_hist.out
# $gtm_tst/com/view_instancefiles.csh is not used above because it filters out pid/timestamp etc which should also be the same and diff should capture if not

echo "# Now bring down P completely and do 10 more updates on A"
$MSR STOPRCV INST1 INST2 RESERVEPORT
$MSR STOPSRC INST2 INST3
$MSR RUN INST1 '$gtm_dist/mumps -run %XCMD "for i=21:1:30 set ^INST1(i)=i"'

echo "# Now bring up P and do 10 more updates on P. The new 20 updates should stream across Q"
setenv test_replic_suppl_type 1
$MSR STARTRCV INST1 INST2
setenv test_replic_suppl_type 2
$MSR STARTSRC INST2 INST3
$MSR RUN INST2 '$gtm_dist/mumps -run %XCMD "for i=21:1:30 set ^INST2(i)=i"'

$gtm_tst/com/dbcheck.csh -extract
# reset test_replic_suppl_type to the default value of suppl_inst test
setenv test_replic_suppl_type 0
