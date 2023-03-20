#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2014 Fidelity Information Services, Inc	#
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
# GTM-6985 : ORLBK : online_rollback : Explicit Non-TP KILLs causing Implicit TP wrapper
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
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1

$echoline
echo "Jobbing off the SET and KILL routines"
$gtm_exe/mumps -run trestartrootverify >&! last_seqno.txt
$echoline

source $gtm_tst/$tst/u_inref/online_rollback_common.csh 0 50 75

$gtm_tst/com/endtp.csh >>&! endtp.out
$gtm_exe/mumps -run stop^trestartrootverify

$echoline
$MSR SYNC ALL_LINKS
$MSR RUN INST2 "set msr_dont_trace;mv RCVR_${ts}.log{,x};$grep -v MUKILLIP RCVR_${ts}.logx >&! RCVR_${ts}.log"
$gtm_tst/com/dbcheck_filter.csh -extract
