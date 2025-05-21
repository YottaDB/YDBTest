#!/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.  #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

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

# Set-up testareas to be in the current directory so we can upload the artifacts
mkdir testarea{1,2,3}
# tst_dir can only be one test area, the main one
echo "setenv tst_dir ${PWD}/testarea1" >> ~gtmtest/.cshrc
chmod 777 ${PWD}/testarea{1,2,3}
sed -i "s|/testarea|$PWD/testarea|g" /usr/library/gtm_test/tstdirs.csh

# Sudo tests rely on the source code for ydbinstall to be in a specific location
ln -s /Distrib/YottaDB /Distrib/YottaDB/V999_R999

# Set-up some environment variables to pass to the test system
setenv ydb_test_inside_docker 1
set pass_env = "-w CI_PIPELINE_ID -w CI_COMMIT_BRANCH -w ydb_test_inside_docker"

if ( ! -f /YDBTest/com/gtmtest.csh ) then
	# Get list of changed files
	# https://forum.gitlab.com/t/ci-cd-pipeline-get-list-of-changed-files/26847
	set upstream_repo = "https://gitlab.com/YottaDB/DB/YDBTest.git"
	echo "# Add $upstream_repo as remote"
	git remote -v
	git remote | grep -q upstream_repo
	if ($status) git remote add upstream_repo "$upstream_repo"
	git fetch upstream_repo
	set basecommit = `git merge-base HEAD upstream_repo/master`
	set filelist = `git diff --name-only $basecommit`
else
	# Test system passed in /YDBTest
	git config --global --add safe.directory /YDBTest
	set basecommit = `git merge-base HEAD master`
	set filelist = `git diff --name-only $basecommit`
endif

echo "Currently available versions: "
ver

set instream_invokelist_regular = ""
set instream_invokelist_replic = ""
set instream_invokelist_reorg = ""
set instream_invokelist_reorg_replic = ""

# Results collected in result.txt, initially empty
touch result.txt

# List of heavyweight tests we won't run on the pipeline
# Leading and trailing spaces are necessary and relied upon by the =~ operator
set heavyweights = " multisrv_crash unicode_socket rollback_B socket jnl_crash ideminter_rolrec rollback_A recov suppl_inst_B io resil_4 tp gtcm_gnp triggers resil v44003 burst_load manually_start "

# Our AARCH64 runner is slow, so add sudo to the list of heavyweight tests
if (`uname -m` == "aarch64") set heavyweights = "${heavyweights}sudo "

# Print file list so we can find out which tests are running in the pipeline
echo "Filelist changed: "
echo $filelist | sed 's/ /\n/g;'

# For each file, check if it is instream.csh or is inside inref
# If it is, add it so that we invoke the test system with "-t xxx -t yyy -t zzz"
# Reorg tests are added to a separate list, as they are run with -reorg
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
			echo "Skipping test [$test] on pipeline as it is a heavyweight test"
			continue
		endif

		# Is this a regular test?
		grep -q ${test}'.* E$' com/SUITE
		@ is_regular_test = ! $status
		# Is this a reorg test?
		grep -q ${test}'.* E REORG$' com/SUITE
		@ is_reorg_test = ! $status
		# Is this a replic test?
		grep -q ${test}'.* E REPLIC$' com/SUITE
		@ is_replic_test = ! $status
		# Is this a reorg-replic test?
		grep -q ${test}'.* E REPLIC REORG$' com/SUITE
		@ is_reorg_replic_test = ! $status

		# Construct test lists. If test is already there, don't add it again.
		if ($is_reorg_test) then
			if ( "$instream_invokelist_reorg" !~ " *-t $test* " ) then
				set instream_invokelist_reorg = "$instream_invokelist_reorg -t $test "
			endif
		endif
		if ($is_replic_test) then
			if ( "$instream_invokelist_replic" !~ " *-t $test* " ) then
				set instream_invokelist_replic = "$instream_invokelist_replic -t $test "
			endif
		endif
		if ($is_regular_test) then
			if ( "$instream_invokelist_regular" !~ " *-t $test* " ) then
				set instream_invokelist_regular = "$instream_invokelist_regular -t $test "
			endif
		endif
		if ($is_reorg_replic_test) then
			if ( "$instream_invokelist_reorg_replic " !~ " *-t $test* " ) then
				set instream_invokelist_reorg_replic = "$instream_invokelist_reorg_replic -t $test "
			endif
		endif
	endif
end

echo "Regular list: $instream_invokelist_regular"
echo "Replic list: $instream_invokelist_replic"
echo "Reorg test list: $instream_invokelist_reorg"
echo "Reorg replic test list: $instream_invokelist_reorg_replic"

# The test system has the capability of running multiple instreams at once, so let's do that.

if ( "$instream_invokelist_regular" != "" ) then
	su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist_regular"
	if ($status) then
		echo "${instream_invokelist_regular}: FAIL (non-replic)" >> result.txt
	else
		echo "${instream_invokelist_regular}: PASS (non-replic)" >> result.txt
	endif
endif

if ( "$instream_invokelist_replic" != "" ) then
	su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist_replic -replic"
	if ($status) then
		echo "${instream_invokelist_replic}: FAIL (replic)" >> result.txt
	else
		echo "${instream_invokelist_replic}: PASS (replic)" >> result.txt
	endif
endif

if ( "$instream_invokelist_reorg" != "" ) then
	su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist_reorg -reorg"
	if ($status) then
		echo "${instream_invokelist_reorg}: FAIL (reorg)" >> result.txt
	else
		echo "${instream_invokelist_reorg}: PASS (reorg)" >> result.txt
	endif
endif

if ( "$instream_invokelist_reorg_replic" != "" ) then
	su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 $instream_invokelist_reorg_replic -reorg -replic"
	if ($status) then
		echo "${instream_invokelist_reorg_replic}: FAIL (reorg replic)" >> result.txt
	else
		echo "${instream_invokelist_reorg_replic}: PASS (reorg replic)" >> result.txt
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
			echo "Skipping test [$test] on pipeline as it is a heavyweight test"
			continue
		endif

		# Is this a regular test?
		grep -q ${test}'.* E$' com/SUITE
		@ is_regular_test = ! $status

		# Is this a reorg test?
		grep -q ${test}'.* E REORG$' com/SUITE
		@ is_reorg_test = ! $status

		# Is this a replic test?
		grep -q ${test}'.* E REPLIC$' com/SUITE
		@ is_replic_test = ! $status

		# Is this a reorg-replic test?
		grep -q ${test}'.* E REPLIC REORG$' com/SUITE
		@ is_reorg_replic_test = ! $status
		if ($is_reorg_replic_test) then
			set is_reorg_test = 1
			set is_replic_test = 1
		endif

		set reorg_flag = ""
		set replic_flag = ""
		if ($is_reorg_test) set reorg_flag = "-reorg"
		if ($is_replic_test) set replic_flag = "-replic"

		# We define them to prevent undefs
		setenv subtest_list
		setenv subtest_list_non_replic
		setenv subtest_list_replic
		setenv subtest_list_common
		grep "setenv subtest_list" ${test}/instream.csh > instream_setenvs
		source instream_setenvs
		rm instream_setenvs

		set subtest = $file:r:t

		# Regular tests
		if ( " $subtest_list_non_replic " =~ " *$subtest* " || " $subtest_list_common " =~ " *$subtest* " || ( " $subtest_list " =~ " *$subtest* " && $is_regular_test ) ) then
			# If test was invoked as a suite from instream, don't add it to the invoke list
			if ( "$instream_invokelist_regular" !~ " *-t $test* " && "$instream_invokelist_reorg" !~ " *-t $test* " && "$instream_invokelist_replic" !~ " *-t $test* " && "$instream_invokelist_reorg_replic" !~ " *-t $test* " ) then
				echo "Running $test/$subtest $reorg_flag"
			        su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 -t $test -st $subtest $reorg_flag"
				if ($status) then
					echo "$test/${subtest}: FAIL (non-replic)" >> result.txt
				else
					echo "$test/${subtest}: PASS (non-replic)" >> result.txt
				endif
			endif
		# Replic tests
		else if ( " $subtest_list_replic " =~ " *$subtest* " || " $subtest_list_common " =~ " *$subtest* " || ( " $subtest_list " =~ " *$subtest* " && $is_replic_test ) ) then
			# If test was invoked as a suite from instream, don't add it to the invoke list
			if ( "$instream_invokelist_regular" !~ " *-t $test* " && "$instream_invokelist_reorg" !~ " *-t $test* " && "$instream_invokelist_replic" !~ " *-t $test* " && "$instream_invokelist_reorg_replic" !~ " *-t $test* " ) then
				echo "Running $test/$subtest -replic $reorg_flag"
			        su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 -t $test -st $subtest -replic $reorg_flag"
				if ($status) then
					echo "$test/${subtest}: FAIL (replic)" >> result.txt
				else
					echo "$test/${subtest}: PASS (replic)" >> result.txt
				endif
			endif
		# Unclassifiable tests
		else
			# Subtest in the u_inref or outref is not a known subtest. Run whole test.
			# If test was invoked as a suite from instream, don't add it to the invoke list
			if ( "$instream_invokelist_regular" !~ " *-t $test* " && "$instream_invokelist_reorg" !~ " *-t $test* " && "$instream_invokelist_replic" !~ " *-t $test* " && "$instream_invokelist_reorg_replic" !~ " *-t $test* " ) then
				echo "Running $test $reorg_flag $replic_flag"
			        su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -fg -env gtm_ipv4_only=1 -stdout 2 -t $test $reorg_flag $replic_flag"
				if ($status) then
					echo "${test}: FAIL (flags: $reorg_flag $replic_flag)" >> result.txt
				else
					echo "${test}: PASS (flags: $reorg_flag $replic_flag)" >> result.txt
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
