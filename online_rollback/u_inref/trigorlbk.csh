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
#GTM-7138
#    ORLBK : online_rollback : Rolling back triggers
setenv gtm_test_online_rollback_no_max_seqno 1

# for imptp
setenv gtm_test_trigger 1
setenv test_specific_trig_file $gtm_tst/com/imptp.trg
setenv gtm_badchar "no"

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 5 125 1000 1024 4096 1024 4096

$echoline
echo "Start source server and receiver server with journaling enabled"
$MSR START INST1 INST2 RP
get_msrtime
set ts = $time_msr

$echoline
$gtm_exe/mumps -run trigorlbk		>&! trigorlbk.out
$gtm_exe/mumps -run stop^trigorlbk	>&! stop_trigorlbk.out

$echoline
$MSR SYNC ALL_LINKS
$MSR RUN INST2 "set msr_dont_trace;mv RCVR_${ts}.log{,x};$grep -v MUKILLIP RCVR_${ts}.logx >&! RCVR_${ts}.log"
$gtm_tst/com/dbcheck_filter.csh -extract
