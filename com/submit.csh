#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
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
# This shell submits  the GTM tests
#

set format="%Y.%m.%d.%H.%M.%S.%Z"
set alltests_begin = `date +"$format"`
source $gtm_tst/com/set_gtm_machtype.csh

setenv test_pid_file /tmp/__${USER}_test_suite_$$.pid
echo $tst_dir/$gtm_tst_out >>! $test_pid_file
setenv gtm_tst_out_save $gtm_tst_out
setenv gtm_test_debuglogs_dir $ggdata/tests/debuglogs/$gtm_tst_out
mkdir -p $gtm_test_debuglogs_dir
setenv gtm_test_local_debugdir $tst_dir/$gtm_tst_out/debugfiles/
if (! -e $gtm_test_local_debugdir) mkdir -p $gtm_test_local_debugdir
touch $gtm_test_local_debugdir/excluded_subtests.list
touch $gtm_test_local_debugdir/test_subtest.info

source $gtm_tst/com/set_java_supported.csh >>! $gtm_test_local_debugdir/set_java_supported.log

# Don't log timing info if only a subset of subtests will run or if dryrun of test is done
if (($?gtm_test_st_list)||($?gtm_test_dryrun)) then
	unsetenv testtiming_log
endif

# If any settings/configuration needs to be overridden AFTER the test has started, it should go in ~/.gtmtest_settings_override.csh
# The file is not expected to be there BEFORE the test starts, so delete it if present assuming it to be a stray file
if (-e  ~/.gtmtest_settings_override.csh) rm ~/.gtmtest_settings_override.csh

$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/submit.awk -v osmachtype=$gtm_test_os_machtype $submit_tests >>! $run_all

echo "submit.csh PID IS : $$ " >! $tst_dir/$gtm_tst_out/PID
if (! $?test_dont_log_tests_out) then
	echo "`date +$format`,TESTS BEGIN." >>! $tst_dir/$gtm_tst_out/tests.out
endif
#at the very end, run_all should exit the exit status (of failed tests)
echo exit \$stat >>! $run_all

#for debugging@@@
#print out everyting that is set
if ($?test_debug) then
  setenv >! $tst_dir/$gtm_tst_out/env.outfile
endif

source $run_all
set exit_status = $status


$gtm_test_com_individual/clean_and_exit.csh
set alltests_end = `date +"$format"`
set total_runtime = `echo $alltests_begin.$alltests_end | $tst_awk -F \. -f $gtm_tst/com/diff_time.awk -v full=1`
#######################SEND FINAL MAIL##########################
touch $tst_dir/$gtm_tst_out/report.txt
set no_tests = `wc -l $tst_dir/$gtm_tst_out/report.txt| $tst_awk '{print $1}'`
if ($no_tests < 2 ) then
   if !($?test_send_report) setenv test_send_report OFF
endif

if ($?tst_dont_send_mail) then
   if !($?test_send_report) setenv test_send_report OFF
else
   if !($?test_send_report) setenv test_send_report  ON
endif

if ("$test_send_report" == "ON") then
	set short_host = $HOST:r:r:r:r
	if (-e $tst_dir/$gtm_tst_out/submitted_tests) set no_tests = `$grep -v "^#" $tst_dir/$gtm_tst_out/submitted_tests | wc -l | $tst_awk '{print $1}'`
	sort -t : -n -r -k1 -k2 -k3 -k4 $tst_dir/$gtm_tst_out/report.txt > ${TMP_FILE_PREFIX}_final_report_time_sorted
	$grep -w FAILED ${TMP_FILE_PREFIX}_final_report_time_sorted > ${TMP_FILE_PREFIX}_final_report_failed
	$grep -w NOTRUN ${TMP_FILE_PREFIX}_final_report_time_sorted > ${TMP_FILE_PREFIX}_final_report_notrun
	$grep -w PASSED ${TMP_FILE_PREFIX}_final_report_time_sorted > ${TMP_FILE_PREFIX}_final_report_passed
	if ($?test_distributed) then
		$grep NOTRUN_${test_distributed:t}_ ${TMP_FILE_PREFIX}_final_report_time_sorted > ${TMP_FILE_PREFIX}_final_report_distributed
	endif
	set countfail = `wc -l  ${TMP_FILE_PREFIX}_final_report_failed | $tst_awk '{print $1}'`
	set countnotrun = `wc -l  ${TMP_FILE_PREFIX}_final_report_notrun | $tst_awk '{print $1}'`
	set countpass = `wc -l ${TMP_FILE_PREFIX}_final_report_passed | $tst_awk '{print $1}'`
	set count_skipped_distributed = 0
	if ($?test_distributed) then
		set count_skipped_distributed = `wc -l ${TMP_FILE_PREFIX}_final_report_distributed | $tst_awk '{print $1}'`
	endif
	@ countall = $countfail + $countnotrun + $countpass
	@ countall_full = $countall + $count_skipped_distributed
	set st_passed = `$tst_awk '{cnt=cnt+$2} END {print cnt}' $gtm_test_local_debugdir/test_subtest.info`
	set st_failed = `$tst_awk '{cnt=cnt+$3} END {print cnt}' $gtm_test_local_debugdir/test_subtest.info`
	set st_excluded = `$tst_awk '{cnt=cnt+$4} END {print cnt}' $gtm_test_local_debugdir/test_subtest.info`
	echo "Total runtime : $total_runtime " 							>&!  ${TMP_FILE_PREFIX}_final_report
	echo "Subtests - Passed : $st_passed ; Failed : $st_failed ; Excluded : $st_excluded"	>>&! ${TMP_FILE_PREFIX}_final_report
	if ($no_tests != $countall_full) then
		# This means the no.of tests in submitted_tests doesn't match with report.txt
		# List the missing tests in the final report mail
		# Prepare an array of tests that's found in report.txt (eg "basic_0 basic_1")
		# For each of the tests in submitted_test, if the test is not found in the array, print it as missing
		set countall = $no_tests
		set rptlist = `$tst_awk '{print "|"$2"|"}' $tst_dir/$gtm_tst_out/report.txt`
		$tst_awk -v rptlist="$rptlist" '/^[0-9]/ {if ( index(rptlist, "|"$2"_"$1"|") == 0) print }' $tst_dir/$gtm_tst_out/submitted_tests > ${TMP_FILE_PREFIX}_final_report_missing
		set countmissing = `wc -l ${TMP_FILE_PREFIX}_final_report_missing |& $tst_awk '{print$1}'`
		if (! -z ${TMP_FILE_PREFIX}_final_report_missing) then
			echo "-------------" >> ${TMP_FILE_PREFIX}_final_report
			echo "Missing ($countmissing/$countall)" >> ${TMP_FILE_PREFIX}_final_report
			echo "-------------" >> ${TMP_FILE_PREFIX}_final_report
			cat ${TMP_FILE_PREFIX}_final_report_missing >> ${TMP_FILE_PREFIX}_final_report
			echo "" >> ${TMP_FILE_PREFIX}_final_report
		endif
	endif
	if (! -z ${TMP_FILE_PREFIX}_final_report_failed) then
		echo "-------------" >> ${TMP_FILE_PREFIX}_final_report
		echo "Failed ($countfail/$countall)" >> ${TMP_FILE_PREFIX}_final_report
		echo "-------------" >> ${TMP_FILE_PREFIX}_final_report
		cat ${TMP_FILE_PREFIX}_final_report_failed >> ${TMP_FILE_PREFIX}_final_report
		echo "" >> ${TMP_FILE_PREFIX}_final_report
	endif
	if (! -z ${TMP_FILE_PREFIX}_final_report_notrun) then
		echo "-------------" >> ${TMP_FILE_PREFIX}_final_report
		echo "Did Not Run ($countnotrun/$countall)" >> ${TMP_FILE_PREFIX}_final_report
		echo "-------------" >> ${TMP_FILE_PREFIX}_final_report
		cat ${TMP_FILE_PREFIX}_final_report_notrun >> ${TMP_FILE_PREFIX}_final_report
		echo "" >> ${TMP_FILE_PREFIX}_final_report
	endif
	if (! -z ${TMP_FILE_PREFIX}_final_report_passed) then
		echo "-------------" >> ${TMP_FILE_PREFIX}_final_report
		echo "Passed ($countpass/$countall)" >> ${TMP_FILE_PREFIX}_final_report
		echo "-------------" >> ${TMP_FILE_PREFIX}_final_report
		cat ${TMP_FILE_PREFIX}_final_report_passed >> ${TMP_FILE_PREFIX}_final_report
	endif
	if (($exit_status) || ($?countmissing)) then
		set subject="FAILURES"
	else
		set subject="ALL PASS"
	endif
	set subjprefix = ""
	if ($?gtm_test_dryrun) set subjprefix = "DRY RUN "
	if ($?gtm_test_st_list) set subjprefix = "$subjprefix SUBSET "
	set subject="$subjprefix $short_host FINAL REPORT: $subject  $tst_src/$tst_ver $tst_image $tst_dir/$gtm_tst_out"
	mailx  -s "$subject" $mailing_list < ${TMP_FILE_PREFIX}_final_report
	\rm -f ${TMP_FILE_PREFIX}_final_report*
endif
################################################################
if (! $?test_dont_log_tests_out) then
	echo "`date +$format`,ALL TESTS FINISHED." >>! $tst_dir/$gtm_tst_out/tests.out
endif
\rm -f $test_pid_file
if (-e $tst_dir/$gtm_tst_out/failmail.cnt) \rm -f $tst_dir/$gtm_tst_out/failmail.cnt
#\rm -f ${TMP_FILE_PREFIX}_* <- why not?

exit $exit_status
#
