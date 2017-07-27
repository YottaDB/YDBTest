#!/usr/local/bin/tcsh -f

# 3) Add the below two automated test cases (scenario described in detail in the below email).

# 1) Create 3 replication instance files, db and jnl files in 3 different directories. Let us say the instance names are A, B, C.
# 2) Now that the instance file is empty in A, replicate 10 updates from A -> B (i.e. A primary, B secondary).
# 3) Shutdown replication servers in A and B.
# 4) Recreate instance file, db and jnl files in A.
# 5) Now that the instance file is empty in A, replicate 10 updates from A -> C (i.e. A primary, C secondary).
#    Note: These updates should be DIFFERENT from those done in step (2).
# 6) Shutdown replication servers in A and C.
# 7) At this point, B and C have 10 updates each of which was generated from A. But those 10 updates are logically different.
#    Therefore they should be treated as completely out of sync i.e. their resync point should be seqno 1 even though their current
#    jnl seqno is 11.
# 8) Start replication from B -> C (using existing instance files, db and jnl files).

# Should be getting the INSNOTJOINED error in step (8) with v55000 and that is the correct behavior.  With pre-v55000, you wont get
# that and replication will proceed fine between B and C which is incorrect.

$MULTISITE_REPLIC_PREPARE 7
$gtm_tst/com/dbcreate.csh mumps -rec=1000

mkdir orig
cp *.dat *.mjl orig/

setenv needupdatersync 1
$MSR START INST1 INST2 RP
unsetenv needupdatersync
$GTM << EOF
for i=1:1:10 set ^a(i)=i
EOF
$MSR SYNC INST1 INST2
$MSR STOP INST1 INST2
mkdir a_to_b
mv *.dat *.repl *.mjl a_to_b/

cp orig/* .
setenv needupdatersync 1
$MSR START INST1 INST3 RP
unsetenv needupdatersync
$GTM << EOF
for i=1:1:10 set ^b(i*3)=i*3
EOF
$MSR SYNC INST1 INST3
$MSR STOP INST1 INST3

$MSR STARTSRC INST2 INST3 RP
setenv gtm_test_repl_skiprcvrchkhlth 1 ; $MSR STARTRCV INST2 INST3 >&! STARTRCV_INST2_INST3.outx ; unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST3 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message INSNOTJOINED -duration 120 -waitcreation'
$MSR RUN INST3 "$msr_err_chk RCVR_$time_msr.log INSNOTJOINED"
$gtm_tst/com/knownerror.csh $msr_execute_last_out GTM-E-INSNOTJOINED
echo "# The receiver would have exited with the above error. Manually shutdown the update process and passive server"
$MSR RUN INST3 'set msr_dont_chk_stat ; $MUPIP replic -receiver -shutdown -timeout=0 >&! updateproc_shut_IST2INST3.out'
$MSR RUN RCV=INST3 SRC=INST2 '$MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__ >&! passivesrc_shut_INST2INST3.out'
$MSR STOPSRC INST2 INST3
$MSR REFRESHLINK INST2 INST3


# Modify subtest (3a) slightly as follows.
# Instead of A->B followed by A->C, take a case where you have two different directories. Under one, let one
# person do the A->B replication steps (1) to (3). In the other directory, let another person do the A->C
# replication steps (4) through (6). That is, two persons are doing the exact same thing at the exact same
# time in two different directories on the same system with the only exception being the secondary instance
# name (B in one case, C in another case). Even if the system time did not go backward, it is possible that
# the instance A had its history record created with the exact same timestamp in both cases. Therefore,
# we still have the issue of B and C being treated as in-sync when they are actually out-of-sync.
setenv needupdatersync 1
$MSR START INST4 INST5 RP
$MSR START INST6 INST7 RP
unsetenv needupdatersync
$gtm_tst/com/simplegblupd.csh -instance INST4 -count 10
$gtm_tst/com/simplegblupd.csh -instance INST6 -count 10
$MSR STOP INST4 INST5
$MSR STOP INST6 INST7
$MSR STARTSRC INST5 INST7 RP
setenv gtm_test_repl_skiprcvrchkhlth 1 ; $MSR STARTRCV INST5 INST7 >&! STARTRCV_INST5_INST7.outx ; unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST7 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message INSNOTJOINED -duration 120 -waitcreation'
$MSR RUN INST7 "$msr_err_chk RCVR_$time_msr.log INSNOTJOINED"
knownerror $msr_execute_last_out GTM-E-INSNOTJOINED
echo "# The receiver would have exited with the above error. Manually shutdown the update process and passive server"
$MSR RUN INST7 'set msr_dont_chk_stat ; $MUPIP replic -receiver -shutdown -timeout=0 >&! updateproc_shut_IST2INST3.out'
$MSR RUN RCV=INST7 SRC=INST5 '$MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__ >&! passivesrc_shut_INST2INST3.out'
$MSR STOPSRC INST5 INST7
$MSR REFRESHLINK INST5 INST7

# None of the instances are expected to be in sync. No need to specify -extract
$gtm_tst/com/dbcheck.csh
