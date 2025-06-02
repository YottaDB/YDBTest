#!/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
source /usr/library/gtm_test/T999/docker/shared-setup.csh

# This block is active when we are inside of a YDB pipeline
if ( $?CI_COMMIT_BRANCH ) then
	git config --global --add safe.directory `pwd`
	# Link the source code to the directory build_and_install_yottadb.csh is aware of
	ln -s `pwd` /Distrib/YottaDB/V999_R999
	ls -lrt /Distrib/YottaDB/V999_R999/

	set ydb_branch = $CI_COMMIT_BRANCH
	echo "ydb_branch: $ydb_branch"

	# Build the branch if not master
	if ( $ydb_branch != "master" ) /usr/library/gtm_test/T999/docker/build_and_install_yottadb.csh V999_R999 master dbg

	# 7957113 is YDBTest Gitlab project id
	curl -s -k "https://gitlab.com/api/v4/projects/7957113/merge_requests?scope=all&state=opened" > ydbtest_open_mrs.json
	set ydbtest_branches = `jq -r '.[].source_branch' ydbtest_open_mrs.json`
	echo "ydbtest_branches: $ydbtest_branches"

	# Does the YDB branch match the the YDBTest branch?
	if ( $ydb_branch != "master" && " $ydbtest_branches " =~ " *$ydb_branch* " ) then
		# We have a match... grab corresponding YDBTest MR number
		echo "Switch to YDBTest branch $ydb_branch"
		set filter = ".[] | select(.source_branch == \"$ydb_branch\") | .iid"
		set mr_id = `jq -r "$filter" ydbtest_open_mrs.json`

		# We are testing against a specific YDBTest MR branch
		setenv gtm_tst "/usr/library/gtm_test/T999"
		git config --global --add safe.directory $gtm_tst
		pushd $gtm_tst

		set upstream_repo = "https://gitlab.com/YottaDB/DB/YDBTest.git"
		echo "# Add $upstream_repo as remote"
		git remote -v
		git remote | grep -q upstream_repo
		if ($status) git remote add upstream_repo "$upstream_repo"
		git update-ref -d refs/heads/${mr_id}
		git fetch upstream_repo
		git fetch upstream_repo merge-requests/${mr_id}/head:mr-${mr_id}
		# Save and restore the rest of the script as another MR may not have the other script
		cp $gtm_tst/docker/pipeline-run-changed-tests.csh /tmp/pipeline-run-changed-tests.csh
		git checkout mr-${mr_id}
		cp /tmp/pipeline-run-changed-tests.csh $gtm_tst/docker/pipeline-run-changed-tests.csh

		set basecommit = `git merge-base HEAD upstream_repo/master`
		setenv filelist `git diff --name-only $basecommit`
		popd
	endif
	rm ydbtest_open_mrs.json
endif

# Sudo tests rely on the source code for ydbinstall to be in a specific location
ln -s /Distrib/YottaDB /Distrib/YottaDB/V999_R999

if ( $?filelist ) then
	exec $gtm_tst/docker/pipeline-run-changed-tests.csh
else
	pushd $gtm_tst
	set test_list=`echo basic sudo r1* r2* v7*`
	echo "test_list: $test_list"
	popd

	# Choose 3 tests randomly
	set random_test_list=`shuf -n3 -e $test_list`

	# Grab subtests
	foreach test ($random_test_list)
		unsetenv subtest_list_non_replic subtest_list_common subtest_list_replic
		grep "setenv subtest_list_" $gtm_tst/$test/instream.csh > instream_setenvs
		source instream_setenvs
		rm instream_setenvs

		# Choose subtests at random
		set subtest_list_to_randomize_nonreplic="$subtest_list_non_replic $subtest_list_common"
		set subtest_list_to_randomize_replic="$subtest_list_common $subtest_list_replic"

		# Choose 5 non-replic tests at random
		set random_nonreplic_subtest_list=`shuf -n5 -e $subtest_list_to_randomize_nonreplic`
		# Choose 1 replic test at random
		set random_replic_subtest_list=`shuf -n1 -e $subtest_list_to_randomize_replic`
		set random_nonreplic_subtest_list_with_commas=`echo "$random_nonreplic_subtest_list" | tr ' ' ','`
		set random_replic_subtest_list_with_commas=`echo "$random_replic_subtest_list" | tr ' ' ','`

		# if we have tests, run them async, saving results in /tmp/test-testname.txt
		# Note that we use "fg", because if we use "bg", the shell does not know that there are child jobs to "wait" for.
		# using fg with & gives us what we want: run multiple tests concurrently and wait for all of them to finish
		if ( $random_nonreplic_subtest_list_with_commas != "" ) then
			su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -env gtm_ipv4_only=1 -stdout 0 -fg -t $test -st $random_nonreplic_subtest_list_with_commas >>& /tmp/test-${test}.txt" &
		endif
		if ( $random_replic_subtest_list_with_commas != "" ) then
			su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -env gtm_ipv4_only=1 -stdout 0 -fg -t $test -st $random_replic_subtest_list_with_commas -replic >>& /tmp/test-${test}.txt" &
		endif
	end

	# Wait till all tests are finished
	jobs
	wait

	# Status of the script. 1 if any test failed
	set test_status = 0

	# Go through test output directories
	set tstdirs = `grep -h "Test Output Directory   ::" /tmp/test-* | awk -F":: " '{print $2}'`
	foreach tstdir ($tstdirs)
		# Output report, and see if it failed
		# Various looks in report.txt do a loop even though all our invocations will cause a report.txt with a single line
		# This is because report.txt could potentially in the future contain multiple lines
		cat $tstdir/report.txt
		foreach invoke_status (`awk '{print $NF}' $tstdir/report.txt`)
			if ($invoke_status == 'FAILED') set test_status = 1
		end

		# For each test in the report, print outstream.log, and if any of the tests failed, print out the diff
		# Same algorithm as com/submit_test.csh
		foreach invoke_name (`awk '{print $2}' $tstdir/report.txt`)
			set tst_general_dir = $tstdir/$invoke_name
			cat $tst_general_dir/outstream.log
			foreach file (`awk '/^FAIL from / {print $6}' $tst_general_dir/outstream.log`)
				set failedtestname = `echo $file | awk -F "/" '{print $1}'`
				echo "# Diff of $failedtestname follows"
				cat $tst_general_dir/$file
			end
			if (-f $tst_general_dir/diff.log && ! -z $tst_general_dir/diff.log) then
				echo "# diff.log contents follow"
				cat $tst_general_dir/diff.log
			endif
		end
		echo
	end

	exit $test_status
endif
