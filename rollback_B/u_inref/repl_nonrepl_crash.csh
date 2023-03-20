#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : DUAL SITE FAILURE : CASE 1	:: But HREG has replication=off
#
#---------------------------------------------------------------|---------------------------------------
#		     A   					|	      B
#---------------------------------------------------------------|---------------------------------------
#	     P (d - 100, R = 95)				|      	S (d - 95, R = 95)
#	     P (101 - 150, R = 95)				|	    X
#		     	X					|	    X
#	     P (151 - 200, R = 95)				|	    X
#	     P (201 - d, R = 95)				|	S (B = min(95, 95) = 95, LT = none)
#---------------------------------------------------------------|---------------------------------------
#
echo "Test case 77a : Replication configuration"
setenv gtm_test_jobcnt 5
setenv test_sleep_sec 90
setenv test_sleep_sec_short 10
setenv test_debug 1
setenv gtm_test_repl_norepl 1
source $gtm_tst/com/set_crash_test.csh	# sets YDBTest and YDB-white-box env vars to indicate this is a crash test
setenv gtm_test_tp 1
# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv test_specific_trig_file $gtm_tst/com/imptp.trg
setenv gtm_test_sprgde_exclude_reglist HREG	# Since HREG has replication turned off
$gtm_tst/com/dbcreate.csh mumps 9 125-325 900-1150 512,1024,4096 1024 1024 1024
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`

cp h.dat h.dat_orig
$sec_shell "$sec_getenv; cd $SEC_SIDE; cp h.dat h.dat_orig"

echo "GTM Process starts in background..."
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep $test_sleep_sec

# RECEIVER SIDE (B) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_SEC_B_CRASH:"
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh"
# primary continues to run and creates a backlog
sleep $test_sleep_sec

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH"
$gtm_tst/com/primary_crash.csh

# PRIMARY SIDE (A) UP
$pri_shell "cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh bak1 "
set cur_time = `date +%H_%M_%S`
\mv h.dat h_${cur_time}.dat
$MUPIP create -reg=HREG
cp h.dat_orig h.dat
echo "$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo " >>&! rollback1.log
$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >>&! rollback1.log
$grep "successful" rollback1.log

# SECONDARY SIDE (B) UP
$sec_shell "cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2 "
$sec_shell "$sec_getenv; cd $SEC_SIDE; \mv h.dat h_${cur_time}.dat; $MUPIP create -reg=HREG ;cp h.dat_orig h.dat"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'echo $gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo >>&! rollback2.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo "*" >>&! rollback2.log;$grep "successful" rollback2.log'

setenv start_time `date +%H_%M_%S`
echo "Restarting Primary (A)..."
$gtm_tst/com/SRC.csh "." $portno $start_time >& START_${start_time}.out
$gtm_tst/com/srcstat.csh "AFTER_PRI_A_RESTART"
echo "Restart gtm..."
setenv gtm_test_jobid 2
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1

echo "Restarting Secondary (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $start_time < /dev/null "">>&!"" $SEC_SIDE/START_${start_time}.out"
$gtm_tst/com/rfstatus.csh "BOTH_UP:"
sleep $test_sleep_sec_short
echo "Now GTM process will end."
$gtm_tst/com/endtp.csh

$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
