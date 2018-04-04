#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if ("pro" == $tst_image) then
	exit
endif

# With 16K counter semaphore bump per process, the 32K counter overflow happens with just 2 processes
# and prevents exercising white-box code which this test relies upon so disable counter overflow
# in this test by setting the increment value to default value of 1 (aka unset).
unsetenv gtm_db_counter_sem_incr

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 32
setenv gtm_white_box_test_case_count 1

set syslog_before1 = `date +"%b %e %H:%M:%S"`
echo "# Time before the run: GTM_TEST_DEBUGINFO $syslog_before1"
# Not using dbcreate script as we don't want to involve dse or mupip
$GDE exit
$MUPIP create

# The replication on process will go through semop code and trigger the SEMOP_INFO and gtm_procstuckexec mechanism according to the above white box number
($DSE dump -f >&! dse_dump.out & ; echo $! >&! dse_dump.pid) >& bg_dse_dump.out
set dse_pid = `cat dse_dump.pid`
$gtm_tst/com/wait_for_log.csh -log dse_dump.out -message "This message is a part of WBTEST_SEMTOOLONG_STACK_TRACE test"
$MUPIP set -replication=on -reg "*" >& replic_on.logx

echo "# Test if the output file exists"
ls TRACE_SEMOP_INFO* >&! is_SEMOP_INFO_exist.out
if ($status) echo "Was expecting SEMOP_INFO* file created by gtm_procstuckexed mechanism, but not found"
set syslog_after1 = `date +"%b %e %H:%M:%S"`
echo "# Time after the run: GTM_TEST_DEBUGINFO $syslog_after1"
echo "# Check the operator log for the message YDB-I-STUCKACT"
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt "" "STUCKACT"
$grep -E "${dse_pid}.*YDB-I-STUCKACT.*SEMOP_INFO" syslog1.txt | sed 's/.*\(YDB-I-STUCKACT\)/\1/; s/\(.*stack_trace.csh\).*/\1/'
$gtm_tst/com/wait_for_proc_to_die.csh $dse_pid
