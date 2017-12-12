#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test framework sets the below env var to 4x the default value on the ARM boxes to avoid test failures due to
# FILTERTIMEDOUT error in various tests. But in this test we do want to see a FILTERTIMEDOUT error and
# readtimeout.m (the external filter M program) waits for a hardcoded time of 40 seconds all of which
# is coded around the default filter timeout of 64 seconds. So unset the env var.
unsetenv ydb_repl_filter_timeout

echo "External Filter test with delay on 6th entry on receiver side"
# this test has jnl extract output, so let's not change the tn
setenv gtm_test_disable_randomdbtn
setenv gtm_test_mupip_set_version "disable"
setenv gtm_tst_ext_filter_rcvr "$gtm_exe/mumps -run ^readtimeout"
setenv gtm_test_updhelpers 0	# Helpers cause error from rf_sync, so disable them.
$gtm_tst/com/dbcreate.csh mumps 1
setenv rcvrlogfile $SEC_SIDE/RCVR_*.log
setenv startout $SEC_SIDE/START_*.out

# Get the receiver server pid
setenv pidrcvr `$tst_awk '/Receiver server is alive/ {print $2}' $startout`

# extract.awk is used to check external filter log in the receiver side. The stream seqno will be "0" for non-suppl instance and non-zero for suppl instance
set strm_seqno_zero = "TRUE"
if ((1 == $test_replic) && (2 == $test_replic_suppl_type)) then
	set strm_seqno_zero = "FALSE"
endif
alias check_mjf '$tst_awk -f $gtm_tst/mupjnl/inref/extract.awk -v "user=$USER" -v "host=$HOST:r:r:r" '"-v strm_seqno_zero=$strm_seqno_zero" ' \!:*'
#
$GTM<<EOF
tstart
set ^abc0="1234"
set ^abc1="1234"
tcommit
set ^abc2="1234"
set ^abc3="1234"
set ^abc4="1234"
set ^abc5="1234"
tstart
set ^abc6="1234"
set ^abc7="1234"
tcommit
EOF
#
# Wait for the FILTERTIMEDOUT error to first appear in the receiver log.
$gtm_tst/com/wait_for_log.csh -log $rcvrlogfile -message "FILTERTIMEDOUT" -duration 300
if ($status) then
	set nonomatch
	set halftime = ( *FILTERTIMEDOUT_HALF_TIME* )
	set fulltime = ( *FILTERTIMEDOUT_FULL_TIME* )
	unset nonomatch
	if ($#halftime > 1 && $#fulltime == 1) then
		cat <<EOF
TEST-W-WARN: Possible case of MREP C_stack_trace_takes_minutes.

To confirm that anaylsis, do a fulltime listing and journal extract on the secondary.

In the journal extract, the non-TP SET of ^abc5 will precede the subsequent TP by 70 seconds, the
current hang duration of ext_filter/inref/readtimeout.m.

The time stamps on the files from the "halftime" stack trace will exceed or equal the 70 second hang
and there will be no "fulltime" stack trace files.  This means that due to the excessive stack trace
time, the HANG in ^readtimeout expired and the Receiver Server did not notice the timeout condition.

EOF
	endif
endif

# By this time, we expect the receiver server to have shutdown.
$gtm_tst/com/wait_for_proc_to_die.csh $pidrcvr 300
if ($status) then
	echo "TEST-E-RCVRALIVE, receiver server with pid=$pidrcvr is still alive. Verify if FILTERTIMEDOUT error was seen above"
endif

# Print the FILTERTIMEDOUT message
$gtm_tst/com/check_error_exist.csh $rcvrlogfile FILTERTIMEDOUT

#
echo "Expect DATABASE EXTRACT to fail due to external filter timeout on receiver side"
$gtm_tst/com/dbcheck.csh -extract
echo
echo "Globals on secondary after readtimeout:"
cat sec*.glo
