#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
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
	foreach file (`$tst_awk '/^FAIL from / { print $6}' $tst_general_dir/outstream.log` )
		echo ""							>>! ${TMP_FILE_PREFIX}_mail
		$grep -w $file:h $tst_general_dir/timing.subtest	>>! ${TMP_FILE_PREFIX}_mail
		echo "--- $file ---"					>>! ${TMP_FILE_PREFIX}_mail
		if (`wc -l $tst_general_dir/$file |  $tst_awk '{print $1}'`> $max_lines ) then
			set basename = $tst_general_dir/${file:r}
			set gunzipped = 0
			set errors_exist = 0
			if (-e $basename.log_actual.gz) then
				$tst_gunzip $basename.log_actual.gz
				set gunzipped = 1
				set errors_exist = 1
			else if (-e $basename.log_actual) then
				set errors_exist = 1
			endif
			# If -E-, -W- etc. type of errors exist, then include all of that in the failure email
			if ($errors_exist) then
				@ actuallines = `wc -l $basename.log_actual | $tst_awk '{print $1}'`
				echo "# ###########################################################"	>>! ${TMP_FILE_PREFIX}_mail
				echo "# Checking for errors in ${basename:t}.log_actual"		>>! ${TMP_FILE_PREFIX}_mail
				echo "# ###########################################################"	>>! ${TMP_FILE_PREFIX}_mail
				set log_out_file = $basename.log_actual
				source $gtm_tst/com/errors_helper.csh					>>! ${TMP_FILE_PREFIX}_mail
				echo									>>! ${TMP_FILE_PREFIX}_mail
				if ($gunzipped) then
					$tst_gzip $basename.log_actual	# Undo the gunzip done above
				endif
				@ actuallines = $actuallines + 1
				echo "# ###########################################################"	>>! ${TMP_FILE_PREFIX}_mail
				echo "# tail -n +$actuallines ${basename:t}.log"			>>! ${TMP_FILE_PREFIX}_mail
				echo "# ###########################################################"	>>! ${TMP_FILE_PREFIX}_mail
				$tail -n +$actuallines $basename.log					>>! ${TMP_FILE_PREFIX}_mail
				echo									>>! ${TMP_FILE_PREFIX}_mail
			endif
			# The actual diff might be huge so only include a small portion of the head/tail
			# of it in the email. To avoid a huge failure email.
			echo "# ###########################################################"	>>! ${TMP_FILE_PREFIX}_mail
			echo "# head -n $headlines $file"					>>! ${TMP_FILE_PREFIX}_mail
			echo "# ###########################################################"	>>! ${TMP_FILE_PREFIX}_mail
			$head -n $headlines $tst_general_dir/$file				>>! ${TMP_FILE_PREFIX}_mail
			echo									>>! ${TMP_FILE_PREFIX}_mail
			echo "# ###########################################################"	>>! ${TMP_FILE_PREFIX}_mail
			echo "# \$tail -n $taillines $file"					>>! ${TMP_FILE_PREFIX}_mail
			echo "# ###########################################################"	>>! ${TMP_FILE_PREFIX}_mail
			$tail -n $taillines $tst_general_dir/$file				>>! ${TMP_FILE_PREFIX}_mail
			echo									>>! ${TMP_FILE_PREFIX}_mail
			echo "... more in the diff file: $file"					>>! ${TMP_FILE_PREFIX}_mail
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
