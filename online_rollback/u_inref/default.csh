#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test verifies that the default behavior for rollback is -noonline
# We do not want the default behavior for rollback to be -online
# 5)	MUPIP JOURNAL -ROLLBACK default behaviour (default.csh)
# 	-	NOONLINE is the default behaviour. Test the default behaviour(ONLINE vs NOONLINE)

$echoline
echo "Start source server and receiver server with journaling enabled"

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 3 125 450 512 4096 1024 4096

$echoline
echo "Start source server and receiver server with journaling enabled"
$MSR START INST1 INST2 RP
get_msrtime
set ts = $time_msr

# start some imptp updates
setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_jobcnt 5
$gtm_tst/com/imptp.csh >>&! imptp.out

# wait for at least 800 updates or 2 minutes
$gtm_exe/mumps -run waituntilseqno "jnl" 0 800 120 >>&! last_seqno.csh

$echoline
echo "Rollback without a qualifier or with -noonline"
set rlbkmethod=`$gtm_exe/mumps -run chooseamong "" -noonline`
set ts1 = `date +"%b %e %H:%M:%S"`
# Below backward rollback invocation is expected to fail. Therefore pass "-backward" explicitly to mupip_rollback.csh
# (and avoid implicit "-forward" rollback invocation that would otherwise happen by default.
echo '$gtm_tst/com/mupip_rollback.csh -backward $rlbkmethod *' >&! rlbk.outx
$gtm_tst/com/mupip_rollback.csh -backward $rlbkmethod "*" 	>>& rlbk.outx
# The sed expression below takes care of filtering out the SHMID field in the MUJPOOLRNDWNFL message spewed out by ROLLBACK
$grep -E '(GTM-E-|JNLSUCCESS|ORLBKCMPLT)' rlbk.outx |& sed 's/id = [0-9]*/id = ##SHMID##/'
sleep 1  # force time to advance to avoid overlapping syslog time stamps
set ts2 = `date +"%b %e %H:%M:%S"`
echo $ts2						>>&! orlbk.outx
echo "Should not see Online Rollback in syslog"
$gtm_tst/com/getoper.csh "$ts1" "$ts2" syslog_noonline.txt
$tst_awk -f $gtm_tst/$tst/inref/orlbksyslogreport.awk td="${PWD:h:h:t}" syslog_noonline.txt
$echoline
echo "Rollback with -online"
echo '$gtm_tst/com/mupip_rollback.csh -online *' 	>>& orlbk.outx
$gtm_tst/com/mupip_rollback.csh -online "*" 		>>& orlbk.outx
$grep -E '(GTM-E-|JNLSUCCESS|ORLBKCMPLT)' orlbk.outx
echo "Should see Online Rollback in syslog"
$gtm_tst/com/getoper.csh "$ts2" "" syslog_online.txt "" "ORLBKCMPLT.*${PWD:h:h:t}"
$tst_awk -f $gtm_tst/$tst/inref/orlbksyslogreport.awk td="${PWD:h:h:t}" syslog_online.txt

$echoline
echo "Stop imptp and shut down the source server"
$gtm_tst/com/endtp.csh >>&! endtp.out

$echoline
$MSR SYNC ALL_LINKS
$MSR RUN INST2 "set msr_dont_trace;mv RCVR_${ts}.log{,x};$grep -v MUKILLIP RCVR_${ts}.logx >&! RCVR_${ts}.log"
$gtm_tst/com/dbcheck_filter.csh -extract
