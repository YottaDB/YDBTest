#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
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
# White box testing is disabled for the PRO builds
if ("pro" == $tst_image) then
	exit
endif
setenv gtm_test_jnl NON_SETJNL
set banner = "#####################################################################"
echo $banner
echo "# Test case 1: gtmprocstuck_get_stack_trace.csh works fine"
set syslog_before1 = `date +"%b %e %H:%M:%S"`
$GDE exit
$MUPIP create

echo "# Time before test case 1 : GTM_TEST_DEBUGINFO $syslog_before1"
echo "# Starting the dse process now"
($gtm_tst/$tst/u_inref/do_dse_flush.csh 1 >>& dse_flush.out_1&) >&! dse_flush.log_1
$gtm_tst/com/wait_for_log.csh -log  do_dse_flush.started_1
$gtm_tst/$tst/u_inref/get_dse_pid.csh 1
if (0 != $status) echo "Did not get DSE PID, status: $status"
# HERE WAIT FOR THE DSE PROCESS TO EXIT
$gtm_tst/com/wait_for_log.csh -log do_dse_flush.done_1
echo "# Test if the output file exists"
ls TRACE_WRITERSTUCK* | $tst_awk '{sub(/WRITERSTUCK_.*/,"WRITERSTUCK_##FILTERED##");print $0;exit}'
mkdir test1
mv TRACE_WRITERSTUCK* test1

# Put in timing info for getoper
set syslog_after1 = `date +"%b %e %H:%M:%S"`
echo "# Time after test case 1 : GTM_TEST_DEBUGINFO $syslog_after1"
# Check if the error/messages are logged in operator log
set dsepid = `cat dse.pid_1`
echo "# Check the operator log for the messages YDB-I-STUCKACT and YDB-E-WRITERSTUCK"
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1a.txt "" STUCKACT
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1b.txt "" WRITERSTUCK
$grep "YDB-I-STUCKACT" syslog1a.txt | $grep $dsepid | sed 's/.*\(YDB-I-STUCKACT\)/\1/; s/\(.*stack_trace.csh\).*/\1/'
$grep "YDB-E-WRITERSTUCK" syslog1b.txt | $grep $dsepid | sed 's/.*\(YDB-E-WRITERSTUCK\)/\1/; s/\(.*mumps.dat\).*/\1/'

echo ""
echo $banner
echo "# Test case 2: Check the code exits gracefully in case of error"
cp $gtm_tst/com/gtmprocstuck_get_stack_trace.csh .
echo "# Remove execute permission from the file"
chmod -x gtmprocstuck_get_stack_trace.csh
setenv gtm_procstuckexec `pwd`/gtmprocstuck_get_stack_trace.csh
set syslog_before2 = `date +"%b %e %H:%M:%S"`
echo "# Time before test case 2 : GTM_TEST_DEBUGINFO $syslog_before2"
echo "# Starting the dse process now"
($gtm_tst/$tst/u_inref/do_dse_flush.csh 2 >>& dse_flush.out_2&) >&! dse_flush.log_2
# Get PID of the dse process
# Depending on the OS the actual error message might differ slightly
# Use the tool to check if one of the specified pattern of error message appears
# If an OS prints a different message, tweak the below or include a new parameter at the end. ref.file fix not needed
$gtm_tst/com/wait_for_log.csh -log do_dse_flush.started_2
$gtm_tst/$tst/u_inref/get_dse_pid.csh 2
if (0 != $status) echo "Did not get DSE PID, status: $status"
# HERE WAIT FOR THE DSE PROCESS TO EXIT
$gtm_tst/com/wait_for_log.csh -log do_dse_flush.done_2
# Put in timing info for getoper
set syslog_after2 = `date +"%b %e %H:%M:%S"`
echo "# Time after test case 2 : GTM_TEST_DEBUGINFO $syslog_after2"
echo "# Check if 'permission denied' or 'cannot execute' error is issued"
$gtm_tst/com/check_string_exist.csh dse_flush.out_2 ANY "gtmprocstuck_get_stack_trace.csh.*ermission denied" "gtmprocstuck_get_stack_trace.csh.*cannot execute"
echo "# Check that WRITERSTUCK file is not generated now"
ls | $grep "^TRACE_WRITERSTUCK"
# Check if the error/messages are logged in operator log
echo "# Check the operator log for the messages YDB-I-STUCKACT and YDB-E-WRITERSTUCK"
$gtm_tst/com/getoper.csh "$syslog_before2" "" syslog2a.txt "" STUCKACT
$gtm_tst/com/getoper.csh "$syslog_before2" "" syslog2b.txt "" WRITERSTUCK
set dsepid = `cat dse.pid_2`
$grep "YDB-I-STUCKACT" syslog2a.txt | $grep $dsepid | sed 's/.*\(YDB-I-STUCKACT\)/\1/; s/\(.*stack_trace.csh\).*/\1/'
$grep "YDB-E-WRITERSTUCK" syslog2b.txt | $grep $dsepid | sed 's/.*\(YDB-E-WRITERSTUCK\)/\1/; s/\(.*mumps.dat\).*/\1/'

echo ""
echo $banner
echo "# Test case 3: File does not exist"
setenv gtm_procstuckexec `pwd`/noexist.csh
set syslog_before3 = `date +"%b %e %H:%M:%S"`
echo "# Time before test case 3 : GTM_TEST_DEBUGINFO $syslog_before3"
echo "# Starting the dse process now"
($gtm_tst/$tst/u_inref/do_dse_flush.csh 3 >>& dse_flush.out_3&) >&! dse_flush.log_3
# Get PID of the dse process
$gtm_tst/com/wait_for_log.csh -log do_dse_flush.started_3
$gtm_tst/$tst/u_inref/get_dse_pid.csh 3
if (0 != $status) echo "Did not get DSE PID, status: $status"
# HERE WAIT FOR THE DSE PROCESS TO EXIT
$gtm_tst/com/wait_for_log.csh -log do_dse_flush.done_3
# Put in timing info for getoper
set syslog_after3 = `date +"%b %e %H:%M:%S"`
echo "# Time after test case 3 : GTM_TEST_DEBUGINFO $syslog_after3"
# Depending on the OS the actual error message might differ slightly
# Use the tool to check if one of the specified pattern of error message appears
# If an OS prints a different message, tweak the below or include a new parameter at the end. ref.file fix not needed
echo "# Check if 'File not found' or 'no such file' error is issued"
$gtm_tst/com/check_string_exist.csh dse_flush.out_3 ANY "noexist.csh.*not found" "noexist.csh.*such file"
echo "# Check that WRITERSTUCK file is not generated now"
ls | $grep "^TRACE_WRITERSTUCK"
# Check if the error/messages are logged in operator log
echo "# Check the operator log for the messages YDB-I-STUCKACT and YDB-E-WRITERSTUCK"
set dsepid = `cat dse.pid_3`
$gtm_tst/com/getoper.csh "$syslog_before3" "" syslog3a.txt "" STUCKACT
$gtm_tst/com/getoper.csh "$syslog_before3" "" syslog3b.txt "" WRITERSTUCK
$grep "YDB-I-STUCKACT" syslog3a.txt | $grep $dsepid | sed 's/.*\(YDB-I-STUCKACT\)/\1/; s/\(.*noexist.csh\).*/\1/'
$grep "YDB-E-WRITERSTUCK" syslog3b.txt | $grep $dsepid | sed 's/.*\(YDB-E-WRITERSTUCK\)/\1/; s/\(.*mumps.dat\).*/\1/'

# End of test
