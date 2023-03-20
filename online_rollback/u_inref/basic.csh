#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
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
# 1. Basic working of online rollback     (basic.csh)
#	--> Start source and receiver server with multiple regions
#	--> Do imptp kind of updates for about 60 seconds in the background.
#	--> Determine the sequence number after the 60 seconds wait (with processes still running). Call it X
#	--> Do an online rollback with -resync=X/2;
#	--> Filter out the DBROLLEDBACK messages in the MJE files
#	--> Do an endtp to ensure all the updates are done with
#	--> Shutdown everything and verify dbcheck (including application verification passes) on both the instances

$echoline
echo "Start source server and receiver server with journaling enabled"
setenv gtm_test_online_rollback_no_max_seqno 1

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 5 125-320 256-600 512,512,768,1024 -allocation=4096 -global_buffer=1024 -extension=4096

$echoline
echo "Start source server and receiver server with journaling enabled"
$MSR START INST1 INST2 RP
get_msrtime

# start some imptp updates
setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_jobcnt 5
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1

# There should be 5 imptp jobs and 1 source server attached to the DEFAULT region
$DSE dump -fileheader >&! refcount1.out
$tst_awk '/Reference count/ {if($2 < 6){print "TEST-F-FAIL: Reference count too low, expected 6 or more\n"FILENAME":"$0}}' refcount1.out

source $gtm_tst/$tst/u_inref/online_rollback_common.csh 0 800 120 "resync"

$echoline
# There should be 5 imptp jobs and 1 source server attached to the DEFAULT region
$DSE dump -fileheader >&! refcount2.out
$tst_awk '/Reference count/ {if($2 < 6){print "TEST-F-FAIL: Reference count too low, expected 6 or more\n"FILENAME":"$0}}' refcount2.out
$gtm_tst/com/endtp.csh >>&! endtp.out

$echoline
echo "Validate Source log for Online Rollback"
#TODO#$MSR RUN INST1 'ls SRC_[0-9][0-9]_[0-9][0-9]_[0-9][0-9]_[0-9][0-9].log'

$echoline
echo "Validate Receiver log for Online Rollback"
$MSR RUN INST2 'set msr_dont_trace;$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message "ONLINE FETCHRESYNC ROLLBACK completed" -duration 300 -waitcreation'
$MSR RUN INST2 'set msr_dont_trace;$grep -v MUKILLIP RCVR_'$time_msr'.log' |& $tst_awk '/REPL_ROLLBACK_FIRST/{s++}{if(s>2){print $0}}/ONLINE FETCHRESYNC ROLLBACK/{if(s++>3){exit(0)}} ' >&! rcv_orlbk.outx
source roll_seqno.csh
$tst_awk -f $gtm_tst/$tst/inref/checkoutput.awk rollseqno=$roll_seqno jnlseqno=$curr_jnl_seqno resyncseqnolist=$curr_resync_seqnos rcv_orlbk.outx

$echoline
echo "Check syslog for Online Rollback messages from both primary and secondary sides"
$gtm_tst/com/getoper.csh "$ts1" "" orlbksyslog.txt "" "ORLBKCMPLT.*${PWD:h:h:t}"
# expect STARTs and STOPs from the primary and secondary sides
$tst_awk -f $gtm_tst/$tst/inref/orlbksyslogreport.awk td="${PWD:h:h:t}" checknostop=1 orlbksyslog.txt

$echoline
echo "Validate the combined logs for Online Rollback"
$MSR RUN INST2 'set msr_dont_trace;cat RCVR_[0-9][0-9]_[0-9][0-9]_[0-9][0-9]_[0-9][0-9].log.updproc' |& $tst_awk '/ONLINE ROLLBACK/{s++}{if(s+0){print $0}}/New Triple Content/{if(s+0){exit(0)}}' > updproc_orlbk.outx
$echoline

$echoline
$MSR SYNC ALL_LINKS
$MSR RUN INST2 "set msr_dont_trace;mv RCVR_'$time_msr'.log{,x};$grep -v MUKILLIP RCVR_'$time_msr'.logx >&! RCVR_'$time_msr'.log"
# If SSL/TLS is enabled for this test, then use this opportunity to also verify that the SSL/TLS session is reused. Since online
# rollback causes the connection to break and reconnect, it can help us test for session reuse.
# TODO: Since SSL/TLS session reuse is temporarily disabled, don't check for Session Reuse. The below code can be uncommented when
# session reuse is re-enabled.
# if ("TRUE" == "$gtm_test_tls") then
# 	$grep -q "Session Reused: YES" SRC_$time_msr.log
# 	if (0 != $status) then
# 		echo "TEST-E-TLS, Session Reuse is expected, but not found. Check SRC_$time_msr.log"
# 	endif
# endif
$gtm_tst/com/dbcheck_filter.csh -extract
