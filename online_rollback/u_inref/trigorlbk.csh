#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
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
# The trigorlbk invocation above would have in turn spawned off an online rollback. That could have taken the current
# instance back to an older seqno. So, if the source server has not yet connected to the receiver server after the
# online rollback, it is possible the last transaction written to the journal pool (jnlpool_ctl->jnl_seqno : which is updated
# by the online rollback process to the post-rollback jnl seqno) could be smaller than the last transaction sent by source server
# (gtmsource_local->read_jnl_seqno : which is updated by the source server once a connection is established with the receiver
# server). Before invoking $MSR SYNC (which will in turn invoke RF_sync.csh) ensure the source server has connected to the
# receiver server and gtmsource_local->read_jnl_seqno has been updated by the source server as otherwise RF_sync.csh would
# error out with an error message of the below form causing a false test failure.
#	RFSYNC-E-SEQNO receiver seqno 39293 is greater than source seqno 37150
$gtm_exe/mumps -run waitreadseqnoupdate^trigorlbk	>&! wait_trigorlbk.out

$MSR SYNC ALL_LINKS
$MSR RUN INST2 "set msr_dont_trace;mv RCVR_${ts}.log{,x};$grep -v MUKILLIP RCVR_${ts}.logx >&! RCVR_${ts}.log"
$gtm_tst/com/dbcheck_filter.csh -extract
