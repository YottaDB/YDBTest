#!/bin/tcsh
#################################################################
#								#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
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
		# Check for a matching YDBEncrypt MR and check it out before building
		echo "### Checking for matching YDBEncrypt MR for branch: $ydb_branch"
		curl -s -k "https://gitlab.com/api/v4/projects/15234426/merge_requests?scope=all&state=opened&source_branch=${ydb_branch}" > /tmp/ydbencrypt_mr.json
		set encrypt_mr_id = `jq -r '.[].iid' /tmp/ydbencrypt_mr.json`
		rm /tmp/ydbencrypt_mr.json
		if ( "$encrypt_mr_id" != "" ) then
			git -C /Distrib/YDBEncrypt fetch origin merge-requests/${encrypt_mr_id}/head:mr-${encrypt_mr_id}
			git -C /Distrib/YDBEncrypt checkout mr-${encrypt_mr_id}
		endif
		if ( $?CI_PROJECT_DIR ) then
			# If running in the pipeline, make sure the build output is in a location that can be included in the artifacts
			/usr/library/gtm_test/T999/docker/build_and_install_yottadb.csh V999_R999 master dbg >& $CI_PROJECT_DIR/pipeline-test-ydb-build.out
		else
			# Otherwise, just use the current directory
			/usr/library/gtm_test/T999/docker/build_and_install_yottadb.csh V999_R999 master dbg >& pipeline-test-ydb-build.out
		endif

		# YDB pipeline should calculate coverage, not YDBTest pipeline
		# Set this var for shared scripts to use
		setenv calculate_coverage 1
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
		# This checkout replaces this script too, but this shell keeps running the version it started
		# with, as the checkout unlinks the file it is reading and puts a new one in its place. So
		# everything past this point that a YDBTest MR may want to change lives in the scripts this one
		# execs below; those are read only after the checkout, so the MR's version of them is what runs.
		git checkout mr-${mr_id}

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
echo " "

if ( $?filelist ) then
	echo "### There are changed tests, run those:"
	exec $gtm_tst/docker/pipeline-run-changed-tests.csh
else
	echo "### There are no changed tests, so run 3 random tests"
	exec $gtm_tst/docker/pipeline-run-random-tests.csh
endif
