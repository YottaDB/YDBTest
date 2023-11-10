#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
####################################################################################################
# Important note: If $MSR needs to be used in this script, make sure it is used as
# $MSR RCV=target_inst SRC=INST1 '...'
# so that $pri_shell does not get changed, which will cause trouble with the execution of
# this script down the line.
####################################################################################################
#
umask 002
set short_host = $HOST:ar
if ($?gtm_test_st_list) then
	setenv subtest_list `echo $gtm_test_st_list| sed 's/,/ /g'`
endif
set testfilesdir = $tst_general_dir/testfiles
if (! -e $testfilesdir) mkdir -p $testfilesdir

set subtest_exclude_list_merged = ""
# Filter out tests from $subtest_exclude_list.
if ($?subtest_exclude_list) then
	set subtest_exclude_list_merged = ($subtest_exclude_list_merged $subtest_exclude_list)
endif
# Filter out tests from $gtm_test_<testname>_exclude_list (both $gtm_test_triggers_exclude_list and $gtm_test_triggers_1_exclude_list)
# Subtests can temporarily disabled by setting this environment variable via say ~/.testrc or -env
if (`eval echo '$?gtm_test_'$tst'_exclude_list'`) then
	set subtest_exclude_list_merged = ($subtest_exclude_list_merged `eval echo '$gtm_test_'$tst'_exclude_list'` )
endif
if (`eval echo '$?gtm_test_'$testname'_exclude_list'`) then
	set subtest_exclude_list_merged = ($subtest_exclude_list_merged `eval echo '$gtm_test_'$testname'_exclude_list'` )
endif
# Note that if say gtm_test_triggers_1_exclude_list is set to "trig2notrig" but the test is run as -replic -num_runs 10,
# the value of testname will be triggers_0_1,triggers_0_2 etc which won't match gtm_test_triggers_1_exclude_list.
# Setting gtm_test_triggers_exclude_list "trig2notrig" would still work in that case.

foreach sub_test ($subtest_exclude_list_merged)
	# We double all space in the sed command so multiple occurence of the same ' $sub_test ' will all be removed.
	# We add a space at the start and end of $subtest_list so ' $sub_test ' can be matched in those position.
	# We have to use spaces around $sub_test to ensure no partial string match.
	setenv subtest_list `echo " $subtest_list " | sed "s/ /  /g; s/ $sub_test / /g"`
	echo "$testname/$sub_test" >> $gtm_test_local_debugdir/excluded_subtests.list
end

if ($?test_gtm_gtcm) then
	if ("GT.CM" == $test_gtm_gtcm) then
		# Even though this is a GT.CM test (means no replication servers are started), gtm_repl_instance is defined to
		# mumps.repl. But, mumps.repl is never created. So, unsetenv gtm_custom_errors to avoid any FTOKERR/ENO2 errors
		# from MUPIP utilties due to non-existent mumps.repl
		unsetenv gtm_custom_errors
	endif
endif
#########################################################################
# If instream has modified settings.csh, it should be reflected in all the subtests' settings.csh file
# So, copy it from the subtest(i.e tmp now) directory to the test directory
# If instream.csh hasn't modified it, it will be the same as the copy in the test directory. So copy it without any checks
set settings_file_to_copy = "$tst_general_dir/settings.csh.$tst"
cp $tst_working_dir/settings.csh $settings_file_to_copy

foreach sub_test ($subtest_list)
	echo "PASS from $sub_test" >>&! $tst_general_dir/outstream.cmp
	if ($?gtm_test_dryrun) then
		echo PASS from $sub_test
	endif
end
if (! -e $tst_general_dir/outstream.cmp) then
	# Probably no subtests were applicable/included. Just touch outstream.cmp to make the framework happy
	touch $tst_general_dir/outstream.cmp
endif
if ($?gtm_test_dryrun) then
	# If it is a -dry run, skip the entire script. Just print PASS for each of the subtests in $subtest_list (done above) and exit
	exit
endif

foreach sub_test ($subtest_list) # Mega for - practically all this script is in this for loop
	setenv test_subtest_name $sub_test
	setenv tst_working_dir "$tst_working_dir:h/$sub_test"
	setenv test_jnldir     "$test_jnldir:h/$sub_test"
	setenv test_bakdir     "$test_bakdir:h:h/$sub_test/bak"
	if ($?test_replic) then
		setenv PRI_DIR  "$PRI_DIR:h/$sub_test"
		setenv PRI_SIDE "$PRI_SIDE:h/$sub_test"
		setenv SEC_DIR  "$SEC_DIR:h/$sub_test"
		setenv SEC_SIDE "$SEC_SIDE:h/$sub_test"
		if ("$sec_getenv" =~ "*${SEC_DIR:h}*") setenv sec_getenv "$sec_getenv:h/$sub_test"
		setenv test_remote_jnldir "$test_remote_jnldir:h/$sub_test"
		setenv test_remote_bakdir  "$test_remote_bakdir:h:h/$sub_test/bak"
		if ("MULTISITE" != "$test_replic") then
			set rmtdirs = "$SEC_DIR"
			if ("$test_remote_jnldir" != "$SEC_DIR") set rmtdirs = "$rmtdirs $test_remote_jnldir"
			if ("$test_remote_bakdir:h" != "$SEC_DIR") set rmtdirs = "$rmtdirs $test_remote_bakdir"
			$sec_shell "mkdir $rmtdirs ; chmod g+w $rmtdirs"
		endif
	else if ("GT.CM" == $test_gtm_gtcm) then
		setenv PRI_DIR         "$PRI_DIR:h/$sub_test"
		setenv sec_dir_gtcm    "$sec_dir_gtcm:h/$sub_test"
		setenv sec_getenv_gtcm "$sec_getenv_gtcm:h/$sub_test"
		setenv SEC_DIR_GTCM_1  "$SEC_DIR_GTCM_1:h/$sub_test"
		setenv SEC_DIR_GTCM_2  "$SEC_DIR_GTCM_1:h/$sub_test"
		$sec_shell "SEC_SHELL_GTCM mkdir -p SEC_DIR_GTCM ; chmod g+w SEC_DIR_GTCM"
	endif
	mkdir $tst_working_dir
	if ("$test_jnldir"   != "$tst_working_dir") mkdir $test_jnldir
	if ("$test_bakdir:h" != "$tst_working_dir") mkdir $test_bakdir
	cd $tst_working_dir
	# Copy the settings.csh file from test directory to this subtest directory
	cp $settings_file_to_copy $tst_working_dir/settings.csh
	echo "------------------"		>>&! $tst_general_dir/config.log
	echo "SUB_TEST: $sub_test"		>>&! $tst_general_dir/config.log
	set sub_test_csh = $gtm_tst/$tst/u_inref/$sub_test.csh.$tst_ver
	if (!(-f $sub_test_csh)) then
		set sub_test_csh = $gtm_tst/$tst/u_inref/$sub_test.csh
	endif
	echo "Using script:         $sub_test_csh"  	>> $tst_general_dir/config.log

	set outref_txt = $gtm_tst/$tst/outref/$sub_test.txt.$tst_ver
	if (!(-f $outref_txt)) then
		set  outref_txt = $gtm_tst/$tst/outref/$sub_test.txt
	endif
	echo "Using reference file: $outref_txt"	>> $tst_general_dir/config.log

	#######################################################
	# check if there is enough space for this subtest, and exit if not
	# for each subtest, move the check_space.out to the subtest dir so that
	# it does not overwrite the check_space.out for the test. - 10/29/02 - zhouc
	if (! $?gtm_test_dryrun) then
		$gtm_tst/com/check_space.csh >&! check_space.out
		if !($status) then
			rm check_space.out
		else
			echo "TEST-E-SPACE, Will not run subtest $tst, sub_test $sub_test due to lack of space: " >> &! $sub_test.diff
			cat $tst_general_dir/check_space.out >> &! $sub_test.diff
			chmod -R g+w .
			#disk_space_mailed.txt shows whether another test encountered the problem earlier
			if (!(-e $tst_dir/$gtm_tst_out/disk_space_mailed.txt)) then
				touch $tst_dir/$gtm_tst_out/disk_space_mailed.txt
				if (! ($?tst_dont_send_mail)) then
					(echo "The subtests that are after this will not be run either (unless disk fress up till then). This is the only warning that will be sent." ; cat ../$sub_test/$sub_test.diff) | mailx -s "$short_host will NOT RUN due to LACK OF SPACE $tst_ver $tst_image $tst $sub_test $tst_general_dir" $mailing_list
				endif
			endif
			exit 1
		endif
	endif


	##################
	source $gtm_tst/com/collation_setup.csh
	##################
	# Reset the gtmroutines value based on the gtm_chset value chosen above
	if ($?gtm_chset) then
		if ("UTF-8" == $gtm_chset) then
			source $gtm_tst/com/set_gtmroutines.csh "UTF8"
		else
			source $gtm_tst/com/set_gtmroutines.csh "M"
		endif
	else
		# If gtm_chset is not set, gtmroutines should point to the M objects/sources and not UTF-8
		source $gtm_tst/com/set_gtmroutines.csh "M"
	endif
	\rm *.o >&! rm_chsetobjs_subtest.log # remove all objs that are compiled till this point
	#
	# Note that the test might override the following
	if ($?gtm_chset) then
		set gtm_chsettmp = $gtm_chset
	else
		set gtm_chsettmp = "undefined"
	endif
	if ($?gtm_test_dbdata) then
		set gtm_test_dbdatatmp = $gtm_test_dbdata
	else
		set gtm_test_dbdatatmp = "undefined"
	endif
	##################
	#
	#########################################################################
	if ($?test_replic) then
		if ($tst_org_host != $tst_remote_host) $gtm_tst/com/send_env.csh
	else if ("GT.CM" == $test_gtm_gtcm) then
		$gtm_tst/com/send_env.csh
	endif

	$gtm_tst/com/subtest_helperlogs.csh "Before" "$gtm_tst" "$tst_working_dir" ""
	if ($?test_replic) then
		if ("MULTISITE" == "$test_replic") then
			$rsh $tst_remote_host_ms_1 "$gtm_tst/com/subtest_helperlogs.csh 'Before' '$gtm_tst' '$tst_remote_dir_ms_1/$gtm_tst_out/$testname/$sub_test' ''"
			$rsh $tst_remote_host_ms_2 "$gtm_tst/com/subtest_helperlogs.csh 'Before' '$gtm_tst' '$tst_remote_dir_ms_2/$gtm_tst_out/$testname/$sub_test' ''"
		else
			$sec_shell "$gtm_tst/com/subtest_helperlogs.csh 'Before' '$gtm_tst' '$SEC_DIR' ''"
		endif
	else if ("GT.CM" == $test_gtm_gtcm) then
		$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; $gtm_tst/com/subtest_helperlogs.csh 'Before' '$gtm_tst' SEC_DIR_GTCM ''"
	endif

	setenv > env_begin.txt
	set format="%Y.%m.%d.%H.%M.%S.%Z"
	set before = `date +"$format"`	# Subtest start time
	if !($?gtm_test_dryrun) then
			# On a lot of boxes a tcsh bug is showing up, when if the switch_chset happens inside the subtest it will not be
			# in effect for subsequent multibyte filenames/dirnames creation. So to avoid the issue we do a
			# switch_chset to UTF-8 even before getting into the subtest
			# NOTE: This happens only when unicode_testlist is defined with the respective
			# subtest in instream.csh or gtm_chset has been randomly chosen as UTF-8
			if ($?unicode_testlist) then
				if (`echo $unicode_testlist|$grep -w "$sub_test"|wc -l`) then
					$switch_chset "UTF-8" >>&! switch_chset_submit_subtest.out
				endif
			endif
			if ($?gtm_chset) then
				if ($gtm_chset == "UTF-8") $switch_chset "UTF-8" >>&! switch_chset_submit_subtest.out
			endif
		# Test if tcsh, throws any error before starting the subtest.
		# This will ensure that the subtest is not submitted in the home directory. The error normally comes up when the PWD has been deleted from any other terminal. The below command will throw up the error: "No such file or directory" in that case and thus could be a sign of things to come.
		$tst_tcsh $gtm_tst/com/eval.csh >& test_tcsh.log
		if($status) then
				echo "TEST-E-DIR Exiting from submit_subtest"
				exit 6
		endif
		# For the sake of completeness, check that PWD is not home
		$gtm_tst/com/chkPWDnoHome.csh
		if($status) exit 6
		setenv tst_tslog_file $sub_test.log_ts
		set skip_subtest = 0
		if ($?subtest_list_common && $?subtest_list_non_replic && $?subtest_list_replic) then
			# This test defined the above 3 env vars in its instream.csh.
			# That lets us do some simplistic checks.
			# If "sub_test" is in "subtest_list_replic" and not in "subtest_list_common"
			# (i.e. it is a replic-only subtest), check if "-replic" was not specified. If so, issue error.
			# If "sub_test" is in "subtest_list_non_replic" and not in "subtest_list_common"
			# (i.e. it is a non-replic-only subtest), check if "-replic" was specified. If so, issue error.
			set is_replic_only = 0
			set is_non_replic_only = 0
			foreach subtst ($subtest_list_non_replic)
				if ($subtst == $sub_test) then
					set is_non_replic_only = 1
				endif
			end
			foreach subtst ($subtest_list_replic)
				if ($subtst == $sub_test) then
					set is_replic_only = 1
				endif
			end
			foreach subtst ($subtest_list_common)
				if ($subtst == $sub_test) then
					set is_replic_only = 0
					set is_non_replic_only = 0
				endif
			end
			if ($?test_replic) then
				if ($is_non_replic_only) then
					echo "TEST-E-APPLIC: Subtest [$sub_test] must be run without [-replic]." >>&! $sub_test.log
					set skip_subtest = 1
				endif
			else
				if ($is_replic_only) then
					echo "TEST-E-APPLIC: Subtest [$sub_test] must be run with [-replic]." >>&! $sub_test.log
					set skip_subtest = 1
				endif
			endif
		endif
		if (! $skip_subtest) then
			# tst_tslog_filter may have a pipe in it, so use eval to interpret it properly.
			eval "$tst_tcsh $sub_test_csh $tst_tslog_filter >>&! $sub_test.log"
		endif
	else
		echo PASS from $sub_test
		end
		exit
	endif
	# take it through a filter to filter out most common run-specific outputs
	if (-e priorver.txt) then	# for tests that use a random prior version
		set priorver = `cat priorver.txt`
	else
		set priorver = "IMPOSSIBLEVERNAME"
	endif
	mv $sub_test.log $sub_test.log_actual
	$gtm_tst/com/do_outstream_m_filter.csh $sub_test.log_actual $sub_test.log_m
	set mask_jnleod = 1
	if (-f dont_mask_jnleod.txt) set mask_jnleod = 0 # The test specifically asks for NOT masking the 'End of Data' field
	$tst_awk -f $gtm_tst/com/outstream.awk -v priorver=$priorver -v mask_jnleod=$mask_jnleod $sub_test.log_m > $sub_test.log
	set dusage = `du -ks $tst_working_dir | $tst_awk '{print $1}'`
	echo $dusage $sub_test >>! $tst_general_dir/du.out

	######
	if (-e $tst_working_dir/settings.csh) cp $tst_working_dir/settings.csh $gtm_test_debuglogs_dir/${testname}_${sub_test}_settings.csh
	##############
	$gtm_tst/com/errors.csh $sub_test endoftest >>&! $sub_test.log
	if ($?test_replic) then
		if ("MULTISITE" != "$test_replic") then
			$sec_shell "$sec_getenv; cd $SEC_DIR; $gtm_tst/com/errors.csh . endoftest" >>&! $sub_test.log
		else
			#we know there were multiple directories (on multiple hosts) were involved, but not how many
			#let's pick up that info:
			$MULTISITE_REPLIC_PREPARE 0	#i.e. use the current values
			$MULTISITE_REPLIC_ENV
			foreach instx (`echo $gtm_test_msr_oneinstperhost | sed 's/INST1 //g;s/INST1$//g'`)
				$MSR RUN RCV=$instx SRC=INST1 'set msr_dont_trace; cd ..; $gtm_tst/com/errors.csh . endoftest' >>&! $sub_test.log
			end
		endif
	else if ("GT.CM" == $test_gtm_gtcm) then
		($sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; cd SEC_DIR_GTCM; $gtm_tst/com/errors.csh . endoftest") >>&! $sub_test.log
	endif
	######
	setenv > env.txt
	if (-e $outref_txt) then
		$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk  $sub_test.log $outref_txt >&! $sub_test.cmp
	else
		echo "TEST-E-NOTFOUND Reference file $outref_txt not found" >&! $sub_test.cmp
	endif
	######
	# To cope with the different style of error messages in OS/390
	if ($HOSTOS == "OS/390") then
		mv $sub_test.log $sub_test.log_edc
		mv $sub_test.cmp $sub_test.cmp_edc
		cat $sub_test.log_edc | tr -d "\000" | sed 's/%SYSTEM-E-EN.*,//g' | \
			sed 's/EDC[0-9][0-9][0-9][0-9][A-Z] \(.*\)\./\1/g' > $sub_test.log
	        cat $sub_test.cmp_edc | tr -d "\000" | sed 's/%SYSTEM-E-EN.*,//g' | \
			sed 's/EDC[0-9][0-9][0-9][0-9][A-Z] \(.*\)\./\1/g' > $sub_test.cmp
	endif
	unset zip_them
	if ($?LC_CTYPE) then
		if ("C" != $LC_CTYPE) then
			set save_lc_ctype=$LC_CTYPE
			# This is because at least in HP-UX we have trouble in diff command
			# when one of the file in question is not ascii text
			setenv LC_CTYPE "C"
		endif
	endif
	# errors.csh prints ERRORS-E-CORE_RENAME when it renames cores by dbx or tcsh. (check the reason for rename in errors.csh).
	# Remove those messages before doing a diff. If there is no other diff, continue to ignore the ERRORS-E-CORE_RENAME message and let the subtest pass
	$grep "ERRORS-.-CORE_RENAME" $sub_test.log >>&! check_rename_messages.outx
	if !($status) then
		\mv $sub_test.log $sub_test.log_rename_messages
		$grep -v "ERRORS-.-CORE_RENAME" $sub_test.log_rename_messages >&! $sub_test.log
		cmp -s $sub_test.cmp $sub_test.log
		if ($status) then
			# It means there were other failures. So retain the ERRORS-E-CORE_RENAME message in the log file
			\mv $sub_test.log_rename_messages $sub_test.log
		endif
	endif

	\diff $sub_test.cmp $sub_test.log  >&! $sub_test.diff
	set diffstatus = $status
	# restore LC_CTYPE here
	if ($?save_lc_ctype) then
		setenv LC_CTYPE $save_lc_ctype
	endif
	$gtm_tst/com/subtest_helperlogs.csh "After" "$gtm_tst" "$tst_working_dir" "$diffstatus"	>>&! $sub_test.log
	if ($?test_replic) then
		if ("MULTISITE" == "$test_replic") then
			$rsh $tst_remote_host_ms_1 "$gtm_tst/com/subtest_helperlogs.csh 'After' '$gtm_tst' '$tst_remote_dir_ms_1/$gtm_tst_out/$testname/$sub_test' '$diffstatus'"	>>&! $sub_test.log
			$rsh $tst_remote_host_ms_2 "$gtm_tst/com/subtest_helperlogs.csh 'After' '$gtm_tst' '$tst_remote_dir_ms_2/$gtm_tst_out/$testname/$sub_test' '$diffstatus'"	>>&! $sub_test.log
		else
			$sec_shell "$gtm_tst/com/subtest_helperlogs.csh 'After' '$gtm_tst' '$SEC_DIR' '$diffstatus'"	>>&! $sub_test.log
		endif
	else if ("GT.CM" == $test_gtm_gtcm) then
		$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; $gtm_tst/com/subtest_helperlogs.csh 'After' '$gtm_tst' SEC_DIR_GTCM '$diffstatus'"	>>&! $sub_test.log
	endif
	if ($diffstatus != 0) then
		# If the subtest failed, do a diff once more to have "Broken pipe" messages caught by subtest_helperlogs.csh, if any
		# Additionally, sometimes we see diff not show the entire diff but just one line like the following.
		#	Binary files use_backup_and_recover.cmp and use_backup_and_recover.log differ
		# This usually happens because of some binary character in the output (e.g. ^@).
		# Because of just one binary character, the entire diff is lost and one has to then see the actual diff
		# manually after removing the binary character. To avoid this manual step, we strip out binary characters
		# (if any) using a "tr" command before redoing the diff. We find if the file has any binary data through the
		# "file" command which returns "data" in that case.
		foreach file ($sub_test.cmp $sub_test.log)
			set filetype = `file -b $file`
			if ("data" == "$filetype") then
				# It is a binary file. Remove the binary characters before the diff.
				# Preserve the original binary file with a .orig extension
				mv $file $file.orig
				# Indicate through the diff output that binary characters have been stripped out.
				echo "# This file has binary characters stripped out. See $file.orig for original file contents" > $file
				# The below tr command was obtained from
				# https://alvinalexander.com/blog/post/linux-unix/how-remove-non-printable-ascii-characters-file-unix/
				tr -cd '\11\12\15\40-\176' < $file.orig >> $file
			endif
		end
		\diff $sub_test.cmp $sub_test.log  >&! $sub_test.diff
		echo FAIL from $sub_test. Please check $sub_test/$sub_test.diff and $sub_test/errs_found.logx for errors in time sorted fashion
		set subteststat = "FAIL"
		$gtm_tst/com/check_rare_failures.csh $testname $test_subtest_name $sub_test.diff
		echo "#####Check the errors,if any, in time sorted fashion in logfile: errs_found.logx#####" >>! $sub_test.diff
		$gtm_tst/com/ipcs -a >&! $sub_test.ipc_all.after	# note down the entire system ipc resources in case of failure
		set zip_them
	else
		if ($?tst_keep_output) then
		    set zip_them
		else
		    if ($?test_replic) then
			 if ("MULTISITE" != "$test_replic") then
				 foreach otherdir ($test_remote_jnldir $test_remote_bakdir:h)
					 if ($SEC_DIR != $otherdir) then
						 $sec_shell "$sec_getenv; \$rm -rf $otherdir >& /dev/null"
					 endif
				 end
				 $sec_shell "$sec_getenv; cd $SEC_DIR/..; \$rm -rf $SEC_DIR >& ${sub_test}.rm; mkdir $SEC_DIR"
			 else
				foreach instx (`echo $gtm_test_msr_oneinstperhost | sed 's/INST1 //g;s/INST1$//g'`)
					$MSR RUN RCV=$instx SRC=INST1 'set msr_dont_trace; cd ..; $rm -rf * >& /dev/null'
				end
			 endif
		    else if ("GT.CM" == $test_gtm_gtcm) then
			 $sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; cd SEC_DIR_GTCM; source $gtm_tst/com/subtest_move_rm.csh rm >& /dev/null"
		    endif
		    # set the permissions for entire related directories so we can remove them then do the removal
		    cd ..
		    chmod -R 775 $tst_working_dir >& chmod_${sub_test}.out
		    rm -rf $tst_working_dir
		    if ( -d $test_jnldir ) rm -rf $test_jnldir
		    if ( -d $test_bakdir ) rm -rf $test_bakdir
		endif
		echo PASS from $sub_test
		set subteststat = "PASS"
	endif
	if ($?zip_them) then
		ls -lR > ls_local.out
		if ($?test_replic) then
			if ("MULTISITE" == "$test_replic") then
				foreach instx (`echo $gtm_test_msr_all_instances | sed 's/INST1 //g;s/INST1$//g'`)
					$MSR RUN RCV=$instx SRC=INST1 'set msr_dont_trace; $gtm_tst/com/zip_output.csh __RCV_DIR__'
				end
				foreach instx (`echo $gtm_test_msr_oneinstperhost | sed 's/INST1 //g;s/INST1$//g'`)
				end
			else
				$sec_shell "$sec_getenv; cd $SEC_DIR; hostname; pwd; ls -lR" > ls_remote.out
				foreach otherdir ($test_remote_jnldir $test_remote_bakdir:h)
					if ($SEC_DIR != $otherdir) then
						$sec_shell "$sec_getenv; $gtm_tst/com/zip_output.csh $otherdir"
					endif
				end
				$sec_shell "$sec_getenv; $gtm_tst/com/zip_output.csh $SEC_SIDE"
			endif
		else if ("GT.CM" == $test_gtm_gtcm) then
			$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; cd SEC_DIR_GTCM; $gtm_tst/com/zip_output.csh SEC_DIR_GTCM"
		endif
		foreach otherdir ($test_jnldir $test_bakdir:h)
			if ($tst_working_dir != $otherdir) then
				$gtm_tst/com/zip_output.csh $otherdir
				\chmod -R g+w $otherdir
			endif
		end
		$gtm_tst/com/zip_output.csh $tst_working_dir
	endif
	set after = `date +"$format"`	# Subtest end time
	set test_time = `echo $before.$after | $tst_awk -F \. -f $gtm_tst/com/diff_time.awk -v full=1`
	echo "$sub_test took $test_time from $before to $after : $dusage $subteststat"	>>&! $tst_general_dir/timing.subtest
end # Mega for
