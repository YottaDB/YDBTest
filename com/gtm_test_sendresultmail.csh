#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################


set passfail = "$1"
set short_host = $HOST:r:r:r:r

set subject = ""
if ($?gtm_test_dryrun) set subject = "DRY RUN "
set subj_testname = "$testname"
if ($?gtm_test_st_list) then
	set subj_testname = "$testname/{$gtm_test_st_list}"
endif
set subj_testdetails = "$tst_src/$tst_ver $tst_image $subj_testname $short_host : $tst_general_dir"
set subject="$subject $passfail $subj_testdetails"

if ("PASSED" == "$passfail") then
	(echo "Random options chosen :";$grep -w $testname $tst_dir/$gtm_tst_out/report.txt ; echo ""; cat $tst_general_dir/config.log ) | mailx -s "$subject" $mailing_list
	exit
endif

# To keep it simple, for PASSED case, the script sends mail and exits
# The rest of the script is only for FAILED/HUNG case.
if ("FAILED" == "$passfail") then
	echo "Random options chosen :"						>>! ${TMP_FILE_PREFIX}_mail
	$grep -w $testname $tst_dir/$gtm_tst_out/report.txt			>>&! ${TMP_FILE_PREFIX}_mail
	echo "" 								>>! ${TMP_FILE_PREFIX}_mail
endif
if ($?gtm_test_fail_mail_lines) then
	set max_lines = $gtm_test_fail_mail_lines
else
	set max_lines = 50
endif
@ headlines = $max_lines / 2
@ taillines = $max_lines / 2

cat  $tst_general_dir/diff.log						>>! ${TMP_FILE_PREFIX}_mail
# Check if this test has subtest scheme
if (-e $tst_general_dir/timing.subtest) then
	echo "--------- Subtest level diff follows ---------"		>>! ${TMP_FILE_PREFIX}_mail
	# For each of the diffs, print the head and tail if it is more than $max_lines lines
	# With the update to -stdout options (YDBTest #414) outstream.log lines were changed as well,
	# which affected the contents of the email sent to the user.
	# The lines written to outstream.log depend on the value of $tst_stdout.
	# If $tst_stdout is 0 or 1, the $sub_test/$sub_test.diff entry is present in the following line
	# `Please check $sub_test/$sub_test.diff and $sub_test/errs_found.logx for errors in time sorted fashion`
	if (($tst_stdout == 0) || ($tst_stdout == 1)) then
	    set failed_subtest_diffs=`$tst_awk '/^Please check / { print $3}' $tst_general_dir/outstream.log`
	# If $tst_stdout is 2 or 3, then the $sub_test/$sub_test.diff entry is present in the following line
	# `Following are the contents of $sub_test/$sub_test.diff`
	else
	    set failed_subtest_diffs=`$tst_awk '/^Following are / { print $6}' $tst_general_dir/outstream.log`
	endif
	foreach file ( $failed_subtest_diffs )
		echo ""							>>! ${TMP_FILE_PREFIX}_mail
		$grep -w $file:h $tst_general_dir/timing.subtest	>>! ${TMP_FILE_PREFIX}_mail
		echo "--- $file ---"					>>! ${TMP_FILE_PREFIX}_mail
		if (`wc -l $tst_general_dir/$file |  $tst_awk '{print $1}'`> $max_lines ) then
			echo "# \$head -n $headlines $file"		>>! ${TMP_FILE_PREFIX}_mail
			$head -n $headlines $tst_general_dir/$file	>>! ${TMP_FILE_PREFIX}_mail
			echo "# \$tail -n $taillines $file"		>>! ${TMP_FILE_PREFIX}_mail
			$tail -n $taillines $tst_general_dir/$file	>>! ${TMP_FILE_PREFIX}_mail
			echo "... more in the diff file: $file"		>>! ${TMP_FILE_PREFIX}_mail
		else
			cat $tst_general_dir/$file			>>! ${TMP_FILE_PREFIX}_mail
		endif
	end
endif
set sendto = "$mailing_list"
if ("gglogs" == "$mailing_list") then
	# If the mail is to be sent to gglogs (i.e tests started by gtmtest, most probably weekend E_ALL), copy test assignment owner too
	set testowner = `$gtm_tst/com/gtm_test_gettestowner.csh $tst`
	set subject = "Attn: $testowner $subject"
	set sendto = "$mailing_list,$testowner"
endif
\cat ${TMP_FILE_PREFIX}_mail | mailx -s "$subject" $sendto
\rm ${TMP_FILE_PREFIX}_mail
