#!/usr/local/bin/tcsh -f

# 9) Test that MULTIPLE history records with the SAME start_seqno but different stream_seqno (and histinfo_num value)
#    are handled properly. For example, take the following scenario
#
#	 Non-supplementary        Supplementary
#           LMS cluster 1          LMS cluster 1
#           --------------        -----------
#           |     A      | -----> |     P   |
#           --------------        |   /     |
#                                 |  Q      |
#                                 -----------
#
#    Initially let P start up. Let it NOT connect to Q as yet.
#    Now P's instance file will have a history record written. Do not do any updates on P.
#    Now let A connect to P. It will write a history record in P with the SAME jnl_seqno
#    as the previous history record written by P. If multiple primaries are supported, then
#    try connection X->P where X is a root primary of a different LMS cluster. Let it also
#    write a history record. Now we will have 3 history records all pointing to the same start_seqno.
#    Now do a few updates in each of A, X and P. These will get intermixed in P in some order.
#    Now start receiver server on Q. We expect source server on P to transmit ALL the 3 history
#    records to Q without errors and only then transmit all the updates. Check the instance file
#    on Q to see those 3 history records got sent in the same order as they are seen in P and have
#    the same start_seqno info as on P.

$MULTISITE_REPLIC_PREPARE 1 2
$gtm_tst/com/dbcreate.csh mumps 5 125-425 900-1050 512,768,1024 4096 1024 4096

$MSR STARTSRC INST2 INST3 RP
get_msrtime
$MSR RUN INST2 'set msr_dont_trace ; $gtm_tst/com/wait_for_log.csh -log SRC_'$time_msr'.log -message "ACTIVE mode" -duration 120 -waitcreation'
$MSR RUN INST2 '$MUPIP replic -edit -show mumps.repl' >&! INST2_repl_show1.out
echo "# History record of INST2 should be seen"
$grep -E "Primary Instance Name|Start Sequence Number|Stream" INST2_repl_show1.out
setenv needupdatersync 1 ; $MSR START INST1 INST2 RP ; unsetenv needupdatersync
get_msrtime
$MSR RUN INST2 'set msr_dont_trace ; $gtm_tst/com/wait_for_log.csh -log RCVR_'$time_msr'.log.updproc -message "New History Content" -duration 120 -waitcreation'
$MSR RUN INST2 '$MUPIP replic -edit -show mumps.repl' >&! INST2_repl_show2.out
echo "# History record of INST2 followed by history record of INST1 should be seen"
$grep -E "Primary Instance Name|Start Sequence Number|Stream" INST2_repl_show2.out

$MSR RUN INST1 "setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh" >&! imptp1.out
$MSR RUN INST2 "setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/imptp.csh" >&! imptp2.out
$MSR RUN INST2 '$gtm_tst/com/wait_for_transaction_seqno.csh 1500 SRC 120 INSTANCE3 noerror'
$MSR STARTRCV INST2 INST3
$MSR RUN INST1 "setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh" >&! endtp1.out
$MSR RUN INST2 "setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh" >&! endtp2.out

$MSR SYNC ALL_LINKS

$MSR RUN INST2 '$MUPIP replic -edit -show mumps.repl' >&! INST2_repl_show3.out
$MSR RUN INST3 '$MUPIP replic -edit -show mumps.repl' >&! INST3_repl_show1.out
$grep '^HST ' INST2_repl_show3.out >&! inst2_hist.txt
$grep '^HST ' INST3_repl_show1.out >&! inst3_hist.txt
echo "# In INSTANCE2 replication file, history record of INST2 followed by history record of INST1 should be seen"
$grep -E "Primary Instance Name|Start Sequence Number|Stream" INST2_repl_show3.out
echo "# In INSTANCE3 replication file, history record of INST2 followed by history record of INST1 should be seen"
$grep -E "Primary Instance Name|Start Sequence Number|Stream" INST3_repl_show1.out
echo "# The history records in INST2 and INST3 should be identical"
echo "diff inst2_hist.txt inst3_hist.txt"
diff inst2_hist.txt inst3_hist.txt

$gtm_tst/com/dbcheck.csh -extract
