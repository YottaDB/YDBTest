#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#=====================================================================
$echoline
cat << EOF
## multisite_replic/deadlock_check -- design tests -- Deadlock Check Test
        --------------------------------------------------------------------------
               INST1/P         INST2/S1          INST3/S2          INST4/S3
        --------------------------------------------------------------------------
Step  0:     backup db, journals, instance file
Step  1:     (P) imptp(5sec)   (S)               (S)               (S)
Step  2:     sync and shutdown all
Step  3:     (S)               (P) imptp(5sec)   (S)               (S)
Step  4:     sync and shutdown all
Step  5:     (P) imptp(5sec)                     (S)               (S)
Step  6:     sync and shutdown all
Step  7:     (S)                                 (P) imptp(5sec)   (S)
Step  8:     sync and shutdown all
Step  9:     (P) imptp(5sec)                                       (S)
Step 10:     sync and shutdown all
Step 11:     (S)                                                   (P) imptp(5sec)
Step 12:     sync and shutdown all
Step 13:     restore db, jnl, and instance files on INST2/S1, INST3/S2, INST4/S3
Step 14:     run deadlock_check_actions.csh SRC on INST1/P for INST2/S1, INST3/S2, INST4/S3 concurrently until backlog=0
             run deadlock_check_actions.csh RCV on INST2/S1, INST3/S2, and INST4/S3 concurrently until backlog=0

Note: Since we will wipe out the databases in the end (before the restore), the
instances which will be secondary until then do not need to receive the data
actually, they will anyway restore.
EOF

$echoline
#- Step 0:
$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh . 1 255 32200 32256 10 64

$MSR RUN INST1 'set msr_dont_trace ; $MUPIP replic -instance_create -name=$gtm_test_cur_pri_name '$gtm_test_qdbrundown_parms'; $gtm_tst/com/jnl_on.csh $test_jnldir -replic=on'
$MSR RUN INST2 'set msr_dont_trace ; $MUPIP replic -instance_create -name=$gtm_test_cur_pri_name '$gtm_test_qdbrundown_parms'; $gtm_tst/com/jnl_on.csh $test_jnldir -replic=on'
$MSR RUN INST3 'set msr_dont_trace ; $MUPIP replic -instance_create -name=$gtm_test_cur_pri_name '$gtm_test_qdbrundown_parms'; $gtm_tst/com/jnl_on.csh $test_jnldir -replic=on'
$MSR RUN INST4 'set msr_dont_trace ; $MUPIP replic -instance_create -name=$gtm_test_cur_pri_name '$gtm_test_qdbrundown_parms'; $gtm_tst/com/jnl_on.csh $test_jnldir -replic=on'
$MSR RUN INST1 'mkdir bak1; cp -p {*.dat,*.mjl*,*.repl} bak1'
$MSR RUN INST2 'mkdir bak1; cp -p {*.dat,*.mjl*,*.repl} bak1'
$MSR RUN INST3 'mkdir bak1; cp -p {*.dat,*.mjl*,*.repl} bak1'
$MSR RUN INST4 'mkdir bak1; cp -p {*.dat,*.mjl*,*.repl} bak1'

setenv gtm_test_tptype "ONLINE"
setenv gtm_test_tp "TP"
setenv gtm_process  5
setenv tst_buffsize 33000000

$echoline
echo "#  Prepare the databases:"
#- So the test will do:
#  Steps  1& 2: deadlock_check_preparedb.csh -primary INST1 -secondary INST2,INST3,INST4
#  Steps  3& 4: deadlock_check_preparedb.csh -primary INST2 -secondary INST1 INST3 INST4
#  Steps  5& 6: deadlock_check_preparedb.csh -primary INST1 -secondary INST3 INST4
#  Steps  7& 8: deadlock_check_preparedb.csh -primary INST3 -secondary INST1 INST4
#  Steps  9&10: deadlock_check_preparedb.csh -primary INST1 -secondary INST4
#  Steps 11&12: deadlock_check_preparedb.csh -primary INST4 -secondary INST1
$gtm_tst/$tst/u_inref/deadlock_check_preparedb.csh -primary INST1 -secondary INST2 INST3 INST4
$gtm_tst/$tst/u_inref/deadlock_check_preparedb.csh -primary INST2 -secondary INST1 INST3 INST4
$gtm_tst/$tst/u_inref/deadlock_check_preparedb.csh -primary INST1 -secondary INST3 INST4
$gtm_tst/$tst/u_inref/deadlock_check_preparedb.csh -primary INST3 -secondary INST1 INST4
$gtm_tst/$tst/u_inref/deadlock_check_preparedb.csh -primary INST1 -secondary INST4
$gtm_tst/$tst/u_inref/deadlock_check_preparedb.csh -primary INST4 -secondary INST1

$echoline
echo "#- Step 13:"
echo "#  Let's create a backup at this moment on all instances:"
$MSR RUN INST1 'mkdir bak2; cp -p {*.dat,*.mjl*,*.repl} bak2'
$MSR RUN INST2 'mkdir bak2; cp -p {*.dat,*.mjl*,*.repl} bak2'
$MSR RUN INST3 'mkdir bak2; cp -p {*.dat,*.mjl*,*.repl} bak2'
$MSR RUN INST4 'mkdir bak2; cp -p {*.dat,*.mjl*,*.repl} bak2'

$echoline
echo "# Let's get a snapshot of the instance files at this point:"
$gtm_tst/com/view_instancefiles.csh -printhistory

$echoline
echo "#  Restore original files (db, jnl, replication instance) on INST2, INST3, and INST4"
$MSR RUN INST2 'rm *.dat *.mjl* *.repl; cp -p bak1/* .'
$MSR RUN INST3 'rm *.dat *.mjl* *.repl; cp -p bak1/* .'
$MSR RUN INST4 'rm *.dat *.mjl* *.repl; cp -p bak1/* .'

$echoline
echo "# -- Start a background GTM process to generate a couple of records and stay alive till the end (to keep the jnlpool alive)"
$MSR STARTSRC INST1 INST2 	# start the jnlpool
$gtm_tst/com/simplebgupdate.csh 3000 >>&! bg.out
$gtm_tst/com/wait_for_log.csh -log bg_gtm.out -message "will wait until told to quit" -duration 300 -waitcreation
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -shutdown -instsecondary=__RCV_INSTNAME__ -timeout=0 >& SHUT_12.out'
$gtm_tst/com/check_error_exist.csh SHUT_12.out "Not deleting jnlpool ipcs."
$MSR REFRESHLINK INST1 INST2	# stop the source server manually so we don't get bitten by the "processes attached to jnlpool"

$echoline
echo "#- Step 14:"
echo "#  deadlock_check_actions.csh:"
$MSR RUN SRC=INST1 RCV=INST2 $gtm_tst/$tst/u_inref/deadlock_check_actions.csh SRC
$MSR RUN SRC=INST1 RCV=INST3 $gtm_tst/$tst/u_inref/deadlock_check_actions.csh SRC
$MSR RUN SRC=INST1 RCV=INST4 $gtm_tst/$tst/u_inref/deadlock_check_actions.csh SRC

$MSR RUN RCV=INST2 SRC=INST1 $gtm_tst/$tst/u_inref/deadlock_check_actions.csh RCV
$MSR RUN RCV=INST3 SRC=INST1 $gtm_tst/$tst/u_inref/deadlock_check_actions.csh RCV
$MSR RUN RCV=INST4 SRC=INST1 $gtm_tst/$tst/u_inref/deadlock_check_actions.csh RCV
echo '#  Each of these scripts will continue until the backlog becomes 0 to that receiver.'
echo '#  Wait until there are three done.INSTx files on each instance'
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/deadlock_check_wait.csh 3'
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/deadlock_check_wait.csh 1'
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/deadlock_check_wait.csh 1'
$MSR RUN INST4 '$gtm_tst/$tst/u_inref/deadlock_check_wait.csh 1'

$echoline
echo "#- Wrap up"
echo "Stop the background GTM process"
touch endbgupdate.txt
$gtm_tst/com/wait_for_proc_to_die.csh `sed 's/^\[.*\] //' bg.out`


echo "#- One last round of replicating to secondaries to sync everything"
$MSR START INST1 INST2
$MSR START INST1 INST3
$MSR START INST1 INST4
$MSR SYNC ALL_LINKS # to sync that last ^quit
$MSR STOP ALL_LINKS
$gtm_tst/com/view_instancefiles.csh -printhistory
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3 INST4
#=====================================================================
