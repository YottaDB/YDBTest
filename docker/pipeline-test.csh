#!/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
set echo
set verbose

# Ensure that our hostname does not have dashes as that crashes multiple parts of the test system
# (it converts hostnames into variables)
echo "HOSTNAME: $HOST"

# Preamble
# Start log server; needed by test framework
rsyslogd
# needed to create the /var/log/syslog file; as otherwise it won't exist at start
logger test

# The file is created asynchronously, so this ensures we don't proceed till it's created
while ( ! -e /var/log/syslog)
  sleep .01
end

# Next two seds, fix the serverconf.txt file
## Correct the host; as it differs each time we start docker
sed -i "s/HOST/$HOST/" /usr/library/gtm_test/serverconf.txt
sed -i 's|LOG|/var/log/syslog|' /usr/library/gtm_test/serverconf.txt

# Fix HOST on tstdirs.csh file
sed -i "s/HOST/$HOST/" /usr/library/gtm_test/tstdirs.csh

# Runner job does not set TERM
setenv TERM xterm

if ( ! -f /YDBTest/com/gtmtest.csh ) then
	# Copy over the test system to $gtm_tst
	# This is ineffecient, but not worth optimizing. It copies everything over rather than only changed files.
	setenv gtm_tst "/usr/library/gtm_test/T999"
	rsync . -ar --delete --exclude=.git $gtm_tst
	chown -R gtmtest:gtc $gtm_tst
else
	# Test system passed in /YDBTest, use that
	rm -r /usr/library/gtm_test/T999
	ln -s /YDBTest /usr/library/gtm_test/T999
endif

# Set-up testarea to be in the current directory so we can upload the artifacts
mkdir testarea
echo "setenv tst_dir ${PWD}/testarea" >> ~gtmtest/.cshrc
chmod 777 ${PWD}/testarea
sed -i "s|/testarea1|$PWD|" /usr/library/gtm_test/tstdirs.csh

# Sudo tests rely on the source code for ydbinstall to be in a specific location
ln -s /Distrib/YottaDB /Distrib/YottaDB/V999_R999

# Set-up some environment variables to pass to the test system
setenv ydb_test_inside_docker 1
set pass_env = "-w CI_PIPELINE_ID -w CI_COMMIT_BRANCH -w ydb_test_inside_docker"

if ( ! -f /YDBTest/com/gtmtest.csh ) then
	# Get list of changed files
	# https://forum.gitlab.com/t/ci-cd-pipeline-get-list-of-changed-files/26847
	git fetch origin
	set filelist = `git diff --name-only origin/master`
else
	# Test system passed in /YDBTest
	git config --global --add safe.directory /YDBTest
	set filelist = `git diff --name-only master`
endif

set instream_invokelist = ""

# Results collected in result.txt, initially empty
touch result.txt

# List of heavyweight tests we won't run on the pipeline
# Leading and trailing spaces are necessary and relied upon by the =~ operator
set heavyweights = " multisrv_crash unicode_socket rollback_B socket jnl_crash ideminter_rolrec rollback_A recov suppl_inst_B io resil_4 tp gtcm_gnp triggers resil v44003 burst_load "

# For each file, check if it is instream.csh or is inside inref
# If it is, add it so that we invoke the test system with "-t xxx -t yyy -t zzz"
foreach file ($filelist)
	set filename = $file:t
	set directory_name = `echo $file | cut -d / -f 2`
	# If instream.csh changes, then test the entire test
	if ("instream.csh" == "$filename") then
		set test = `dirname $file`
	# If a file inside inref changes, then test the entire test, as we can't tell which test it belongs to
	else if ( "inref" == "$directory_name" ) then
		set test = `echo $file | cut -d / -f 1`
	endif
	if ( $?test ) then
		# Space delimiters ensure we don't accidentally exclude a test due to partial matching; it needs to be a whole word
		if ( "$heavyweights" =~ "* $test *" ) then
			echo "Skipping test on pipeline as it is a heavyweight test"
			continue
		endif
		# If test is already there, don't add it again
		if ( "$instream_invokelist" !~ "*-t $test*" ) then
			set instream_invokelist = "$instream_invokelist -t $test"
		endif
	endif
end

# The test system has the capability of running multiple instreams at once, so let's do that.

if ( "$instream_invokelist" != "" ) then
	su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -noencrypt -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist"
	if ($status) then
		echo "${instream_invokelist}: FAIL (non-replic)" >> result.txt
	else
		echo "${instream_invokelist}: PASS (non-replic)" >> result.txt
	endif
	su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -noencrypt -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist -replic"
	if ($status) then
		echo "${instream_invokelist}: FAIL (replic)" >> result.txt
	else
		echo "${instream_invokelist}: PASS (replic)" >> result.txt
	endif
endif

# Next, check if the file is "test/u_inref/xxx.csh" or "test/outref/xxx.txt".
# If so, run EACH with -t test/xxx, but only if we didn't previously run the whole "test" before just above.
# We cross check that xxx is found in the subtest_list in test/instream.csh
# Note that we run each sequentially (rather than together as above) because the test system is incapable of combining different -t xxx/yyy -t aaa/bbb
set subtest_non_replic_invokelist = ""
set subtest_replic_invokelist = ""
foreach file ($filelist)
	set directory_name = `echo $file | cut -d / -f 2`
	if ( ( "u_inref" == "$directory_name" ) || ( "outref" == "$directory_name" ) ) then
		set test = `echo $file | cut -d / -f 1`
		if ( "$heavyweights" =~ "* $test *" ) then
			echo "Skipping test on pipeline as it is a heavyweight test"
			continue
		endif
		set subtest = $file:r:t
		# Collect subtests and figure out which ones are replic vs not, as we cannot invoke a non-replic test in replic mode and vice versa
		grep "setenv subtest_list_" ${test}/instream.csh > instream_setenvs
		source instream_setenvs
		rm instream_setenvs
		if ( ! ( $?subtest_list_non_replic ) && ! ( $?subtest_list_common ) && ! ( $?subtest_list_replic ) ) then
			echo "Couldn't find subtest_list_non_replic, subtest_list_common, nor subtest_list_replic in instream.csh"
			continue
		endif
		if ( "$subtest_list_non_replic" =~ "*$subtest*" || "$subtest_list_common" =~ "*$subtest*" ) then
			# If test was invoked as a suite from instream (non-replic), don't add it to the invoke list
			if ( "$instream_invokelist" !~ "*-t $test*" ) then
			        su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -noencrypt -fg -env gtm_ipv4_only=1 -stdout 2 -t $test/$subtest"
				if ($status) then
					echo "$test/${subtest}: FAIL (non-replic)" >> result.txt
				else
					echo "$test/${subtest}: PASS (non-replic)" >> result.txt
				endif
			endif
		else if ( "$subtest_list_replic" =~ "*$subtest*" || "$subtest_list_common" =~ "*$subtest*" ) then
			# If test was invoked as a suite from instream (replic), don't add it to the invoke list
			if ( "$instream_invokelist" !~ "*-t $test*" ) then
			        su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -noencrypt -fg -env gtm_ipv4_only=1 -stdout 2 -t $test/$subtest -replic"
				if ($status) then
					echo "$test/${subtest}: FAIL (replic)" >> result.txt
				else
					echo "$test/${subtest}: PASS (replic)" >> result.txt
				endif
			endif
		else
			# Subtest in the u_inref or outref is not a known subtest. Run whole test.
			# If test was invoked as a suite from instream (replic), don't add it to the invoke list
			if ( "$instream_invokelist" !~ "*-t $test*" ) then
			        su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -noencrypt -fg -env gtm_ipv4_only=1 -stdout 2 -t $test"
				if ($status) then
					echo "${test}: FAIL (non-replic)" >> result.txt
				else
					echo "${test}: PASS (non-replic)" >> result.txt
				endif
			        su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -noencrypt -fg -env gtm_ipv4_only=1 -stdout 2 -t $test -replic"
				if ($status) then
					echo "${test}: FAIL (replic)" >> result.txt
				else
					echo "${test}: PASS (replic)" >> result.txt
				endif
			endif
		endif
	endif
end

# Fail if any of the tests failed
cat result.txt
grep -q FAIL result.txt
# Grep reverses the exit: 0 means found, 1 means not found, not found is good!
exit ( ! $status )
