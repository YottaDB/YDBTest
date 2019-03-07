#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtmgbldir "mumps.gld"
$gtm_tst/com/dbcreate.csh mumps

echo "# Test case 1: Restart source server with a non-replicated previous generation file."
echo "#"
echo "Shut down secondary so a backlog is createad."
setenv start_time `cat start_time`
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log.updproc -message 'New History Content' -duration 120"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
$gtm_exe/mumps -run %XCMD 'set ^a="replicated"'

echo "Shut down primary and turn off replication.  Then, do a (not-replicated but still journaled) transaction."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC_SHUT.csh off < /dev/null >>&! $PRI_SIDE/SHUT_${start_time}.out"
$gtm_tst/com/wait_for_log.csh -log SHUT_${start_time}.out -duration 120 -grep -message "Replication state for region DEFAULT is now OFF"
$gtm_exe/mumps -run %XCMD 'set ^a="not-replicated"'

echo "Turn replication back on and manually break the journal's prev link, by setting it to the 'unreplicated' journal file."
set syslog_before = `date +"%b %e %H:%M:%S"`
setenv start_time "a_"`date +%H_%M_%S`
$MUPIP set -replication=on -reg "*"
$MUPIP set -jnlfile mumps.mjl -prevjnlfile=`ls -1 mumps.mjl_* | $tail -n 1` -bypass
set syslog_after = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog1.txt "" PREVJNLLINKCUT

echo "Restart replication, source server should get the error JNLNOREPL"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""."" $portno < /dev/null >>&! $SEC_SIDE/START_${start_time}.out"
setenv gtm_test_repl_skipsrcchkhlth
$gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null >>&! START_${start_time}.out
unsetenv gtm_test_repl_skipsrcchkhlth
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -duration 120 -grep -message "JNLNOREPL"
set pidsrc = `$grep "Replication Source Server with Pid" SRC_${start_time}.log | $tst_awk '{ print $14 }' | cut -b 2- | cut -d ] -f 1`
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 300
$gtm_tst/com/check_error_exist.csh SRC_${start_time}.log "JNLNOREPL" >&! /dev/null

echo "Fix prev link and restart source server"
set syslog_before = `date +"%b %e %H:%M:%S"`
setenv start_time "b_"`date +%H_%M_%S`
# At this point, there is no source server running and no database shared memory lying around. The MUPIP SET command below
# opens databases and creates shared memory. Since source server has already died, csa->nl->replinstfilename will be NULL
# initialized and if $gtm_custom_errors is defined, the process will try to do jnlpool_init and later will issue a
# REPLINSTMISMTCH error. Temporarily, unsetenv $gtm_repl_instance to avoid this error.
unsetenv gtm_repl_instance
$MUPIP set -replication=on -reg "*"
setenv gtm_repl_instance mumps.repl
$MUPIP set -jnlfile mumps.mjl -prevjnlfile=`ls -1r mumps.mjl_* | $tail -n 1` -bypass
set syslog_after = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog2.txt "" PREVJNLLINKSET
$gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null >>&! START_${start_time}.out
$gtm_tst/com/RF_sync.csh

echo "# Test case 2: Restart source server with a journal file containing no records."
echo "#"
echo "Start with a fresh journal file"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC_SHUT.csh off < /dev/null >>&! $PRI_SIDE/SHUT_${start_time}.out"
$gtm_tst/com/wait_for_log.csh -log SHUT_${start_time}.out -duration 120 -grep -message "Replication state for region DEFAULT is now OFF"
setenv start_time "c_"`date +%H_%M_%S`
$gtm_tst/com/SRC.csh on $portno $start_time < /dev/null >>&! START_${start_time}.out
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -duration 120 -grep -message "GTM Replication Source Server now in ACTIVE mode"

echo "Put a transaction in the backlog and shutdown replication"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
$gtm_exe/mumps -run %XCMD 'set ^a="replicated in backlog"'
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC_SHUT.csh ""."" < /dev/null >>&! $PRI_SIDE/SHUT_${start_time}.out"

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
echo "Truncate journal file so it contains only the header and restart replication.  Source server should get the error JNLRDERR"
cp mumps.mjl mumps.mjl.back_1
dd if=mumps.mjl.back_1 of=mumps.mjl count=64 bs=1024 >>&! dd_1.out
setenv start_time "d_"`date +%H_%M_%S`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""."" $portno < /dev/null >>&! $SEC_SIDE/START_${start_time}.out"
setenv gtm_test_repl_skipsrcchkhlth
$gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null >>&! START_${start_time}.out
unsetenv gtm_test_repl_skipsrcchkhlth
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -duration 120 -grep -message "JNLRDERR"
# This is needed for the cases where the testsystem randomizes custom_error to be the sample file and insterror_on_freeze is turned on
$MUPIP replicate -source -freeze=off >>&! unfreeze.outx
set pidsrc = `$grep "Replication Source Server with Pid" SRC_${start_time}.log | $tst_awk '{ print $14 }' | cut -b 2- | cut -d ] -f 1`
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 300
$gtm_tst/com/check_error_exist.csh SRC_${start_time}.log "JNLRDERR" >&! /dev/null

echo "Fix journal file and restart source server"
setenv start_time "e_"`date +%H_%M_%S`
cp mumps.mjl.back_1 mumps.mjl
$gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null >>&! START_${start_time}.out
$gtm_tst/com/RF_sync.csh

echo "# Test case 3: Restart source server with a journal file containing partial records."
echo "#"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC_SHUT.csh off < /dev/null >>&! $PRI_SIDE/SHUT_${start_time}.out"
$gtm_tst/com/wait_for_log.csh -log SHUT_${start_time}.out -duration 120 -grep -message "Replication state for region DEFAULT is now OFF"
setenv start_time "f_"`date +%H_%M_%S`
$gtm_tst/com/SRC.csh on $portno $start_time < /dev/null >>&! START_${start_time}.out
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -duration 120 -grep -message "GTM Replication Source Server now in ACTIVE mode"

echo "Put some transactions in the backlog and shutdown replication"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
$gtm_exe/mumps -run %XCMD 'for i=1:1:100 set ^a(i)="replicated in backlog"'
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC_SHUT.csh ""."" < /dev/null >>&! $PRI_SIDE/SHUT_${start_time}.out"

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
echo "Truncate journal file so it contains some partial records and restart replication.  Source server should get the error JNLRDERR"
cp mumps.mjl mumps.mjl.back_2
dd if=mumps.mjl.back_2 of=mumps.mjl count=66 bs=1024 >>&! dd_2.out
setenv start_time "g_"`date +%H_%M_%S`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""."" $portno < /dev/null >>&! $SEC_SIDE/START_${start_time}.out"
setenv gtm_test_repl_skipsrcchkhlth
$gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null >>&! START_${start_time}.out
unsetenv gtm_test_repl_skipsrcchkhlth
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -duration 120 -grep -message "JNLRDERR"
# This is needed for the cases where the testsystem randomizes custom_error to be the sample file and insterror_on_freeze is turned on
$MUPIP replicate -source -freeze=off >>&! unfreeze.outx
set pidsrc = `$grep "Replication Source Server with Pid" SRC_${start_time}.log | $tst_awk '{ print $14 }' | cut -b 2- | cut -d ] -f 1`
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 300
$gtm_tst/com/check_error_exist.csh SRC_${start_time}.log "JNLRDERR" >&! /dev/null

echo "Fix journal file and restart source server"
setenv start_time "h_"`date +%H_%M_%S`
cp mumps.mjl.back_2 mumps.mjl
$gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null >>&! START_${start_time}.out
$gtm_tst/com/RF_sync.csh

$gtm_tst/com/dbcheck.csh
