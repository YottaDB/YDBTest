#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
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
# TEST : BURST LOAD TESTING: 6.32
#
#
setenv timefile  "time_no_backup.log"
echo "Buffer Size is $tst_buffsize bytes" >>&! $tst_general_dir/$timefile
#
$gtm_tst/com/dbcreate.csh mumps 4 125 1000 -allocation=2048 -extension_count=2048
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
#
# Force receiver to shut down
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log.updproc -message 'New History Content' -duration 120"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
#
#
# GTM Process starts in background
echo "Starting GTM processes..."
echo "GTM started: `date +%H:%M:%S`" >>&! $tst_general_dir/$timefile
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep $test_backlog_time
echo "Stopping GTM processes..."
$gtm_tst/com/endtp.csh >>& endtp.out
echo "GTM ends at: `date +%H:%M:%S`" >>&! $tst_general_dir/$timefile
#
echo "Now start receiver to clear backlog..."
setenv start_time `date +%H_%M_%S`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $start_time ""helper"" < /dev/null "">>&! "" $SEC_SIDE/START_${start_time}.out"
echo "Clearing backlog started at: `date +%H:%M:%S`" >>&! $tst_general_dir/$timefile
#
$gtm_tst/com/rfstatus.csh "Before_RF_sync_starts:"
$gtm_tst/com/RF_sync.csh
#
echo "Clearing backlog stopped at: `date +%H:%M:%S`" >>&! $tst_general_dir/$timefile
#
$gtm_tst/com/dbcheck.csh -extract
#
cat showbacklog.log >>&! $tst_general_dir/$timefile
ls -l *.dat *.mjl  >>&! $tst_general_dir/$timefile
echo "no_backup burst_load test ends."
echo "Please look at $timefile for timing information."
#
