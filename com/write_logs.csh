#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2005-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# write the log line into tests.out and final report
set short_host="$HOST:r:r:r:r"
set loglinestat = $1
set format="%Y.%m.%d.%H.%M.%S.%Z"
set timestamp = `date +"$format"`
# Depending on where in submit_test.csh, this script is called, it is possible "test_time" env var has not yet been set.
# For example, if "do_random_settings.csh" fails with an error, it is very early in "submit_test.csh".
# In that case, treat it as if it was a NOTRUN case and initialize "tim" to 0s instead of accessing "$test_time".
if (( "$loglinestat" =~ "NOTRUN*") || (0 == $?test_time)) then
	set tim = "00:00:00:00"
else
	set tim = "$test_time"
endif
# $testname could be basic_2 or basic_2_1 (num_runs)
set tst_num = `echo $testname | sed "s/\(${tst}_[0-9]*\).*/\1/g"`
set log_line = "$timestamp,${short_host},${USER},${tst_ver},${tst_image},${tst_num},${tst_src},$loglinestat"
set log_line_report = "$tim	${testname}  $loglinestat"
set log_line_long = `echo $log_line | $tst_awk -f $gtm_tst/com/log_line.awk`

# awk cannot differentiate between unset env.variable and env.variable set to null. For such cases, pass it as parameter
set awk_args = "-v isset_gtm_trace_gbl_name=$?gtm_trace_gbl_name"
if ($?gtm_autorelink_keeprtn) then
	set keeprtn_bool = `$gtm_exe/mumps -run check^randbool $gtm_autorelink_keeprtn`
else
	set keeprtn_bool = 'undef'
endif
set awk_args = "$awk_args -v keeprtn_bool=$keeprtn_bool"

(if (-e $tst_general_dir/settings.csh.$tst) source $tst_general_dir/settings.csh.$tst ; echo $log_line_report | $tst_awk -f $gtm_tst/com/log_report.awk $awk_args >>! $tst_dir/$gtm_tst_out/report.txt)
# The below is used by submit_test. Keep the awk part in sync with the line above
set timinglog_info  = `if (-e $tst_general_dir/settings.csh.$tst) source $tst_general_dir/settings.csh.$tst ; echo "" | $tst_awk -f $gtm_tst/com/log_report.awk $awk_args`

if (! $?test_dont_log_tests_out) then
	echo "$log_line_long,$LFE" >>! $tst_dir/$gtm_tst_out/tests.out
endif

set testresults = $ggdata/tests/testresults/testresults.csv_$short_host
if ($?testresults_log) then
	if ( (! -e $testresults) && (! -e $tst_dir/$gtm_tst_out/testresults.csv_warned) ) then
		(touch $testresults && chmod 664 $testresults) >& /dev/null
		if (-e $testresults) then
			@ perm = `filetest -P664 $testresults`
			if (664 != $perm) then
				set error_message = "Setting 664 permission to the file $testresults failed. Please change ownership to library and provide group write permission"
			else
				set error_message = "Created $testresults file as $USER. Please change ownership to library to be consistent with other files"
			endif
		else
			set error_message = "Creating file $testresults failed. Please create $testresults and provide group write permission"
		endif
		# Send one mail to gglogs about this testresults.csv_${short_host}
		echo "$error_message" >&! $tst_dir/$gtm_tst_out/testresults.csv_warned
		mailx -s "FILE-E-PERMISSON, check $testresults " gglogs  < $tst_dir/$gtm_tst_out/testresults.csv_warned
	endif
	if (-w $testresults) then
		echo "$log_line_long,$LFE">>! $testresults
        endif
endif
