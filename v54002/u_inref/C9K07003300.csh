#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

source $gtm_tst/com/enable_procstuckexec.csh # This test needs ydb_procstuckexec (test framework would have disabled it on armv6l)

setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh mumps 1

setenv gtm_white_box_test_case_count 1
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 32
set syslog_before1 = `date +"%b %e %H:%M:%S"`
echo "Starting DSE in the background"
($gtm_tst/$tst/u_inref/do_dse_halt.csh >>& dse_halt.out&) >&! dse_halt.log
$gtm_tst/com/wait_for_log.csh -log dse_halt.out -message "DSE is ready. MUPIP can start."
source $gtm_tst/$tst/u_inref/get_dse_pid.csh
if (0 != $status) then
	echo "Did not get DSE PID, status: $status. Exiting"
	exit 1
endif
echo "Starting MUPIP SET  command now"
$MUPIP set -extension_count=400 -file mumps.dat
$gtm_tst/com/wait_for_log.csh -log  do_dse.done
echo "# Test if the output file exists"
ls %YDBPROCSTUCKEXEC*_SEMOP_INFO* | sed 's/_[0-9]\{8\}_[0-9]\{6\}_\(SEMOP_INFO\)_[0-9_]*\(.*\)/_YYYYMMDD_HHMMSS_\1*\2/;'
set syslog_after1 = `date +"%b %e %H:%M:%S"`
echo "# Time after processes got over : GTM_TEST_DEBUGINFO $syslog_after1"
# Check if the error/messages are logged in operator log
echo "# Check the operator log for the messages YDB-I-STUCKACT"
 $gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1a.txt "" STUCKACT
 $grep "YDB-I-STUCKACT" syslog1a.txt | $grep SEMOP_INFO | $grep $dsepid | sed 's/.*\(YDB-I-STUCKACT\)/\1/; s/\(.*stack_trace.csh\).*/\1/'
echo ""
# Kill any backgrounded DSE processes (from %YDBPROCSTUCKEXEC) to avoid later TEST-E-LSOF errors from test framework
$gtm_tst/com/kill_ydbprocstuckexec_dse_processes.csh
$gtm_tst/com/dbcheck.csh
