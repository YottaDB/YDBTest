#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
set suppr = "outstream.log"
set shorthost = $HOST:ar
if ( ("" != "$1") && ("." != "$1") ) set suppr = $1.log
# find output is sorted because scylla's find seems to behave differently from other systems
# and creates problems for reference files otherwise.
#
if ("GT.CM" == $test_gtm_gtcm) then
	set nonomatch
	set cmfiles = (GTCM_SERVER_*.log cmerr*.log)
	unset nonomatch
	foreach file (${cmfiles:q})
		if (-f "$file") then
			mv "$file" "${file}_actual"
			$grep -vE "FORCEDHALT|ENO15" "${file}_actual" > "$file"
		endif
	end
endif
touch log_and_out_files.txt
touch err_file_names.logx
foreach pattern ("*.out" "*.log" "*.err*" "*.log.updproc" "*.mje*" "*.mjo*" "*.DMP*")
	# we use a temporary file (file_list.tmp) instead of a pipe to do the find followed by sort because of:
	# - we need to used the current directory for work files for sort since /tmp (or /var/tmp)
	#   is possibly too small on some servers
	# - sort creates temporary files in it's processing, but find is going through the list of files
	#   at the same time, and sort's work files might step on find's toes (find sees the temporary files
	#   at one point, but not later in it's processing)
	find `pwd` -name "$pattern" ! -name "*.gz" >! file_list.tmp
	sort -T . file_list.tmp >>! log_and_out_files.txt
	set stat = $status
	if ($stat) then
		echo "TEST-E-ERRORS_FIND, Could not determine files of type $pattern under directory `pwd`"
		echo $stat
		cat log_and_out_files.txt
	endif
	\rm file_list.tmp
end

# Check if the subtest was a crash test. If so, it is possible %YDBPROCSTUCKEXEC*dse.out files contain various errors
# like %YDB-E-REQROLLBACK etc. because the database was crashed by the time the DSE process invoked by %YDBPROCSTUCKEXEC
# (which could be invoked at an arbitrary point in the test in case of a loaded system etc.). Lots of errors are possible
# in this case so we don't filter out a list of those errors. Instead we exclude %YDBPROCSTUCKEXEC*dse.out files from
# the list of files that go through the errors_helper.csh script in case of a crash test. The test to determine whether
# it is a crash test or not is a crude one and is to check for the existence of the file "gtm_test_crash*.csh". This has been
# found to exist in all the crash tests that so far have caused errors in %YDBPROCSTUCKEXEC*dse.out files. If a new test
# shows up at a later point in time that is a crash test but does not create this file, then we will need to come up with
# a better scheme to detect a crash test.
#
# Note that one better scheme would be to check the "gtm_test_crash" env var which is set by all crash tests/subtests using
# the script "com/set_crash_test.csh" but this env var is set inside the <subtest>.csh script and so the setting is lost when
# we come to this framework script after the <subtest>.csh script is finished. That is why we had to opt for a crude check here.
set filepat="gtm_test_crash_jobs*.csh"
set nonomatch
set filereal=$filepat
unset nonomatch
if ("$filereal" != "$filepat") then
	# Files of the form "gtm_test_crash_jobs*.csh" exist.
	# Implies this is a crash test. Exclude "%YDBPROCSTUCKEXEC*dse.out" files from file list.
	if (! -z log_and_out_files.txt) then
		mv log_and_out_files.txt log_and_out_files.txt.orig
		$grep -v '%YDBPROCSTUCKEXEC.*dse.out' log_and_out_files.txt.orig > log_and_out_files.txt
	endif
endif

if !(-z log_and_out_files.txt) then
	# We have seen that if the file log_and_out_files.txt contains multi-byte characters, tcsh has a bug in that
	# using backslash-quote to cat the above file and loop through each of the file names gives a file-not-found error
	# because tcsh seems to be losing a few bytes of the multi-byte character (in the filename) at 4K page boundaries.
	# To work around that, we generate another .csh file (log_and_out_files.csh) that contains the names of all the files
	# and source another script (errors_helper.csh) which does the error check, thereby avoiding the backslash-quote usage.
	$tst_awk '{printf "(set log_out_file=\"%s\"; source $gtm_tst/com/errors_helper.csh)\n", $0;}' log_and_out_files.txt >! log_and_out_files.csh
	source log_and_out_files.csh
endif

if !(-z err_file_names.logx) then
		$tst_awk 'BEGIN{filelist = ""} {filelist=$0" "filelist} END{print filelist}' err_file_names.logx | xargs ls -lrt | $tst_awk '{print $NF}' | xargs $grep -f $gtm_tst/com/errors_catch.txt /dev/null | $grep -v -f $gtm_tst/com/errors_ignore.txt >! errs_found.logx
endif

# Check if there are core files. Exclude `python/.venv` directory as a whole as it can contain files
# like `core.py` or `core.pyc` which are not core files but will otherwise be treated as one due to their name.
# Not sure if `python` is an immediate subdirectory or could be one or more levels of subdirectory deep.
# Therefore use the `-name .venv` solution instead of a `-path ./python/.venv` solution.
find . \( -name .venv \) -prune -o -type f -a \( -name 'core*' -o -name 'gtmcore*' \) -print >&! CORE.lis
set stat = $status
if ($stat) then
	echo "TEST-E-ERRORS_FIND, Could not determine if there were core files generated under directory `pwd`"
	echo $stat
	cat CORE.lis
else if (! -z CORE.lis) then
	if (-f "errs_found.logx") then
		set assert_reported = `$grep -c GTMASSERT errs_found.logx`
	else
		set assert_reported = 0
	endif
	foreach core (`cat CORE.lis`)
		chmod a+r "$core"
		# report the cores if it has not already been reported in the test output
		if (0 == $assert_reported) then
			# Use the "file" command on Linux and extract out the "execfn" field from the output.
			# Below is a sample output
			# core.31474: ELF 64-bit LSB core file x86-64, version 1 (SYSV), SVR4-style, from 'dbg/mumps -direct', real uid: 28, effective uid: 28, real gid: 1, effective gid: 1, execfn: 'dbg/mumps', platform: 'x86_64'
			# And the below command extracts out the "dbg/mumps" usage that comes after "execfn:" above.
			set exe = `file $core | tr ',' '\n' | grep execfn | awk '{print $2}' | sed "s/'//g"`
			if (! -e "$exe") then
				# Sometimes (e.g. older distributions like Ubuntu 16.04) the output of the "file" command does
				# not contain "execfn:". In that case, the following seems to work (suggestion found at
				#	https://stackoverflow.com/questions/13308922/find-which-program-caused-a-core-dump-file)
				set exe = `strings $core | grep '^/' | tail -1`
			endif
			if (! -e "$exe") then
				# Record the fact that we had a core whose executable was not determined.
				# Signal a test failure for this by generating a "-E-" string that way we find out
				# how to fix that situation and avoid it in future test runs.
				echo "ERRORS.CSH-E-FINDEXE : Could not determine executable of core file [$core]"
			endif
			if ( ("$dbx" == "$exe") || ("tcsh" == "$exe:t") ) then
				# Sometimes GDB cores with "A problem internal to GDB has been detected". Check <gdb_aborts_on_attach>
				# Sometimes tcsh cores with "Segmentation fault (core dumped)" and the rest of the test would pass. Check <tcsh_cores>
				# We have not been able to determine the conditions under which this happens and/or avoid those in the test system.
				# So we rename such cores.This way if the only reason for the test failure is such a core, those false failures will be avoided.
				mv $core ${core}_$exe:t
				echo "ERRORS-E-CORE_RENAME : @ `pwd` $core is renamed to ${core}_$exe:t"
				continue
			endif
			if !($?cores_listed) then
				echo "################################################################"
				if (($?test_replic) || ("GT.CM" == $test_gtm_gtcm)) then
					echo "There are core files ($shorthost, `pwd`):"
				else
					echo "There are core files:"
				endif
				cat CORE.lis
				set cores_listed = 1
			endif
			$gtm_tst/com/get_dbx_c_stack_trace.csh $core $exe
		endif
	end
endif
if (-z CORE.lis) rm CORE.lis
find . -name 'YDB_FATAL*' >&! gtm_fatal.LIS
set stat = $status
if ($stat) then
	echo "TEST-E-ERRORS_FIND, Could not determine if there were YDB_FATAL files generated under directory `pwd`"
	echo $stat
	cat gtm_fatal.LIS
else if (! -z gtm_fatal.LIS) then
	echo "################################################################"
	if (($?test_replic) || ("GT.CM" == $test_gtm_gtcm)) then
		echo "There are YDB_FATAL files ($shorthost, `pwd`):"
	else
		echo "There are YDB_FATAL files"
	endif
	cat gtm_fatal.LIS
	chmod a+r `cat gtm_fatal.LIS`
endif
if (-z gtm_fatal.LIS) rm gtm_fatal.LIS

if ("endoftest" == "$2") then
	set dir_name = "$PWD" # errors.csh by submit_{sub,}test.csh takes care of being in the right dir (for MSR, non-MSR and pri-dir)
	set log_file = lsof_${test_subtest_name}.out
	if ( ( "$shorthost" == "${tst_org_host:ar}" ) && ("$dir_name" != "$tst_working_dir") ) then
		# This is true only on the remote side of a single-host replic test. In that case, we don't log ipcs.b4subtest in the remote side
		set ipcs_file = $tst_working_dir/../../ipcs.b4subtest
	else
		set ipcs_file = ../../ipcs.b4subtest
	endif
	set portgrep = $test_subtest_name
	$lsof |& $grep -w "$dir_name" |& $tst_awk '{if ($1 ~ /dse|mumps|mupip|gdb|dbx|gtcm/) print}' >&! $log_file
	if !(-z $log_file) then
		set sub =  "TEST-E-LSOF some processes are still accessing files in ${shorthost} : ${dir_name}"
		echo "$sub Check $shorthost : $dir_name/$log_file"
		if !($?tst_dont_send_mail) then
			cat $log_file | mailx -s "$sub" $mailing_list
		endif
		# Capture ps -ef state at the time of the LSOF report. This would be helpful in finding out
		# more details on the pids identified in the lsof_* report above.
		ps -ef --forest >& lsof_psfu_${test_subtest_name}.out
	else
		\rm $log_file
		# If there are no processes running, check if there are any ipcs left over
		$gtm_tst/com/check_ipcs.csh all $ipcs_file
	endif

	# Check for left over port reservation files - With the portcleanup deferred, this cannot be done now.
	# $grep "$tst_working_dir $portgrep" /tmp/test_*.txt >&! /dev/null
	if (0) then
		# Even if the test/subtest fails (due to server shut issues ect), just list them here
		# Also on a single-host replic test, the below will be printed twice
		# Since we do not expect this to be printed normally, a double entry is okay instead of having
		# complex logic to avoid it (checking on pri_side and for non-replic tests should be done too)
		echo "ERRORS-E-PORT The below port reservation files are left behind @ $shorthost"
		$grep "$tst_working_dir $portgrep" /tmp/test_*.txt
	endif

endif
