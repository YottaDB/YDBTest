#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$echoline
echo "Start source server and receiver server with journaling enabled"

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 5 125-320 256-600 512,512,768,1024 -allocation=4096 -global_buffer=1024 -extension=4096

$echoline
echo "Start source server and receiver server with journaling enabled"
$MSR START INST1 INST2 RP
get_msrtime
set ts = $time_msr

# start some imptp updates for background noise
setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_jobcnt 3
$gtm_tst/com/imptp.csh >>&! imptp.out

$echoline
echo "Jobbing off the tight loop reader"
$gtm_exe/mumps -run tightloopreader >&! tightloopreader.outx

source $gtm_tst/$tst/u_inref/online_rollback_common.csh 0 100 30

$gtm_exe/mumps -run stop^tightloopreader
$gtm_tst/com/endtp.csh >>&! endtp.out

$echoline
$MSR SYNC ALL_LINKS
$MSR RUN INST2 "set msr_dont_trace;mv RCVR_${ts}.log{,x};$grep -v MUKILLIP RCVR_${ts}.logx >&! RCVR_${ts}.log"
$gtm_tst/com/dbcheck_filter.csh -extract
