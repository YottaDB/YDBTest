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

# Note that some echo commands below include only a space since the GitLab CI
# will not emit newlines unless they are preceded by a printable character.
# So, include a space in the echos that are meant to generate newlines to create the
# desired effect.

# This block is active when we are inside of a YDB pipeline
if ( $?CI_COMMIT_BRANCH ) then
	git config --global --add safe.directory `pwd`

	set ydb_branch = $CI_COMMIT_BRANCH

	if ( $ydb_branch != "master" ) then
		echo " "
		echo "# Build branch if not master"
		ln -s `pwd` /Distrib/YottaDB/V999_R999
		if ( $?CI_PROJECT_DIR ) then
			# If running in the pipeline, make sure the build output is in a location that can be included in the artifacts
			/usr/library/gtm_test/T999/docker/build_and_install_yottadb.csh V999_R999 master dbg >& $CI_PROJECT_DIR/pipeline-test-ydb-build.out
		else
			# Otherwise, just use the current directory
			/usr/library/gtm_test/T999/docker/build_and_install_yottadb.csh V999_R999 master dbg >& pipeline-test-ydb-build.out
		endif
	endif

	echo " "
	# 7957113 is YDBTest Gitlab project id
	curl -s -k "https://gitlab.com/api/v4/projects/7957113/merge_requests?scope=all&state=opened" > ydbtest_open_mrs.json
	set ydbtest_branches = `jq -r '.[].source_branch' ydbtest_open_mrs.json`
	echo "# ydb_branch: $ydb_branch"
	echo "# ydb_branches: $ydbtest_branches"

	# Check whether the YDB branch and YDBTest have the same name and that name is not master."
	# If so, it is a YDBTest MR. In that case, test against that MR branch."
	if ( $ydb_branch != "master" && " $ydbtest_branches " =~ " *$ydb_branch* " ) then
		echo " "
		echo -n "## Matching YDBTest MR found. Get the MR ID: "
		set filter = ".[] | select(.source_branch == \"$ydb_branch\") | .iid"
		set mr_id = `jq -r "$filter" ydbtest_open_mrs.json`
		echo "$mr_id"

		# We are testing against a specific YDBTest MR branch
		setenv gtm_tst "/usr/library/gtm_test/T999"
		git config --global --add safe.directory $gtm_tst
		pushd $gtm_tst >& /dev/null

		set upstream_repo = "https://gitlab.com/YottaDB/DB/YDBTest.git"
		echo "## Add $upstream_repo as remote"
		git remote -v
		git remote | grep -q upstream_repo
		if ($status) git remote add upstream_repo "$upstream_repo"
		git update-ref -d refs/heads/${mr_id}
		git fetch upstream_repo
		git fetch upstream_repo merge-requests/${mr_id}/head:mr-${mr_id}
		echo "## Save and restore the rest of the script as another MR may not have the other script"
		cp $gtm_tst/docker/pipeline-run-changed-tests.csh /tmp/pipeline-run-changed-tests.csh
		git checkout mr-${mr_id}
		cp /tmp/pipeline-run-changed-tests.csh $gtm_tst/docker/pipeline-run-changed-tests.csh

		set basecommit = `git merge-base HEAD upstream_repo/master`
		setenv filelist `git diff --name-only $basecommit`
		popd >& /dev/null
	endif
	rm ydbtest_open_mrs.json
endif

# Sudo tests rely on the source code for ydbinstall to be in a specific location"
#  but if we go through a rebuild of YDB, then it will be already defined, so don't"
#  do it again."
if ( ! -d /Distrib/YottaDB/V999_R999 ) then
	echo " "
	echo "### YDB is already built, just link the existing build"
	ln -s /Distrib/YottaDB /Distrib/YottaDB/V999_R999
endif
echo " "

echo "### Verify contents of source/build directory (/Distrib/YottaDB/V999_R999):"
ls -lrt /Distrib/YottaDB/V999_R999/
find /Distrib/YottaDB/V999_R999/dbg
echo " "

if ( $?filelist ) then
	echo "### There are changed tests, run those:"
	exec $gtm_tst/docker/pipeline-run-changed-tests.csh
else
	echo "### There are no changed tests, so run 3 random tests"
	pushd $gtm_tst >& /dev/null
	echo -n "## Get the full test list: "
	set test_list=`echo basic sudo r1* r2* v7*`
	echo $test_list
	popd >& /dev/null

	echo -n "# Choose 3 tests randomly: "
	set random_test_list=`shuf -n3 -e $test_list`
	echo $random_test_list

	# Grab subtests
	foreach test ($random_test_list)
		echo " "
		echo "### Run randomly chosen test: $test"
		unsetenv subtest_list_non_replic subtest_list_common subtest_list_replic
		grep "setenv subtest_list_" $gtm_tst/$test/instream.csh > instream_setenvs
		source instream_setenvs
		rm instream_setenvs

		set subtest_list_to_randomize_nonreplic="$subtest_list_non_replic $subtest_list_common"
		set subtest_list_to_randomize_replic="$subtest_list_common $subtest_list_replic"
		echo "$subtest_list_to_randomize_replic" | grep -q '[^[:space:]]' >& /dev/null
		if ($status == 0) then
			set replic_present = 1
		else
			set replic_present = 0
		endif

		set random_nonreplic_subtest_list=`shuf -n5 -e $subtest_list_to_randomize_nonreplic`
		set random_nonreplic_subtest_list_with_commas=`echo "$random_nonreplic_subtest_list" | tr ' ' ','`
		echo -n "# For $test non-replic, choose 5 random subtests: "
		echo $random_nonreplic_subtest_list

		if ($replic_present == 1) then
			echo -n "# For $test replic, choose 1 random subtest: "
			set random_replic_subtest_list=`shuf -n1 -e $subtest_list_to_randomize_replic`
			set random_replic_subtest_list_with_commas=`echo "$random_replic_subtest_list" | tr ' ' ','`
			echo $random_replic_subtest_list_with_commas
		endif
		echo " "

		# If we have tests, run them async, saving results in /tmp/test-testname.txt.
		# Note that we use "fg", because if we use "bg", the shell does not know that there are child jobs to "wait" for.'
		# using fg with & gives us what we want: run multiple tests concurrently and wait for all of them to finish"
		if ( $random_nonreplic_subtest_list_with_commas != "" ) then
			echo "# Starting $test non-replic tests:"
			su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -env gtm_ipv4_only=1 -stdout 0 -fg -t $test -st $random_nonreplic_subtest_list_with_commas >>& /tmp/test-${test}.txt" &
		endif
		if ( $?random_replic_subtest_list_with_commas != "" ) then
			echo "# Starting $test replic tests:"
			su -l gtmtest $pass_env -c "/usr/library/gtm_test/T999/com/gtmtest.csh -nomail -env gtm_ipv4_only=1 -stdout 0 -fg -t $test -st $random_replic_subtest_list_with_commas -replic >>& /tmp/test-${test}.txt" &
		endif
	end

	echo " "
	echo "### Wait till all tests are finished"
	jobs
	wait
	echo " "

	# Status of the script. 1 if any test failed
	set test_status = 0

	echo "### Go through test output directories:"
	set tstdirs = `grep -h "Test Output Directory   ::" /tmp/test-* | awk -F":: " '{print $2}'`
	foreach tstdir ($tstdirs)
		echo "## Output report for $tstdir, and see if it failed:"
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
		echo " "
	end

	exit $test_status
endif
