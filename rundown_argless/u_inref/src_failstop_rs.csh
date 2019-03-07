#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013, 2014 Fidelity Information Services, Inc	#
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
#
# TEST : SOURCE SERVER STOPS/FAILS, BACKLOG AND RESTART
#
# This subtest was originally in the "crash_fail" test and inherited some of its env vars from the test level instream.csh.
# That is now moved to a file crash_fail/u_inref/subtest_settings.csh which crash_fail/instream.csh continues to source.
# And this subtest (now in the "rundown_argless" test) sources that script too to avoid duplication of that code.
source $gtm_tst/crash_fail/u_inref/subtest_settings.csh

if !($?gtm_test_replay) then
	set stop_fail_todo = `$gtm_exe/mumps -run rand 2`
	echo "# Randomly chosen stop/fail option : $stop_fail_todo"	>>&! settings.csh
	echo "setenv stop_fail_todo $stop_fail_todo"			>>&! settings.csh
endif

$gtm_tst/com/dbcreate.csh mumps 4 125 1000 4096 2000 4096 2000
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
# GTM Process starts in background
$gtm_tst/com/imptp.csh >&! imptp.out
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror

echo "# Source Server fail/stop"
$gtm_tst/com/rfstatus.csh "Before_Source_FAILURE:"
if ( 0 == "$stop_fail_todo" ) then
	# $kill -9 case
	$gtm_tst/$tst/u_inref/source_fail.csh >&! source_fail.out
else
	# $kill -15 case
	$gtm_tst/$tst/u_inref/source_stop.csh >&! source_stop.out
	mv SRC_${start_time}.log SRC_${start_time}.logx
	$grep -v "YDB-F-FORCEDHALT" SRC_${start_time}.logx >&! SRC_${start_time}.log
endif

# Run argumentless MUPIP RUNDOWN after the source server was kill -9ed (to test GTM-8156)
# Without GTM-8156, the source server restart would issue REPLREQROLLBACK error if gtm_custom_errors env var was set
# Although for GTM-8156, we need to do the rundown only in the case of kill -9, we do it for the kill -15 case too
# for increased test coverage in general.
$MUPIP RUNDOWN >& mupip_rundown.outx
$MUPIP RUNDOWN -relinkctl >& mupip_rundown_ctl.outx

$sec_shell "$sec_getenv; $gtm_tst/com/rcvrstat.csh "AFTER_PRI_DOWN:" < /dev/null"
echo "# More updates"
sleep $test_sleep_sec_short # wait_for_transaction_seqno.csh cannot be used as the src is not alive

echo "# Restart source server"
setenv tst_buffsize 33554432
setenv start_time `date +%H_%M_%S`
$gtm_tst/com/SRC.csh "." $portno $start_time >&! START_${start_time}.out
$gtm_tst/com/rfstatus.csh "AFTER_PRI_RESTART:"


# GTM process continues
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec_short "" noerror

#Now GTM process ends
$gtm_tst/com/endtp.csh >>& endtp.out

$gtm_tst/com/dbcheck.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh

