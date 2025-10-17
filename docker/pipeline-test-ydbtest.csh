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
source /usr/library/gtm_test/T999/docker/shared-setup.csh

# Note that some echo commands below include only a space since the GitLab CI
# will not emit newlines unless they are preceded by a printable character.
# So, include a space in the echos that are meant to generate newlines to create the
# desired effect.

echo " "
pushd /usr/library/gtm_test/T999 >& /dev/null

# https://forum.gitlab.com/t/why-i-cant-get-the-branch-name/72462/6
# Gitlab detaches the git tree (i.e. a checkout creates a detached tree, so rev-parse of HEAD just returns HEAD)
# The rev-parse way is left in order to be able to test this pipeline locally.
if ( $?CI_COMMIT_BRANCH ) then
	set ydbtest_branch = $CI_COMMIT_BRANCH
else
	set ydbtest_branch = `git rev-parse --abbrev-ref HEAD`
endif
echo "# ydbtest_branch: $ydbtest_branch"

set filter = ".[] | select(.source_branch == \"$ydbtest_branch\") | .iid"
echo "# Get the open MR that matches the name of the current YDBTest MR:"
curl -s -k "https://gitlab.com/api/v4/projects/7957109/merge_requests?scope=all&state=opened&source_branch=${ydbtest_branch}" > ydb_mr.json
set ydb_branch = `jq -r '.[].source_branch' ydb_mr.json`

if ( $ydb_branch == "" ) then
	echo "# Branch name matching YDB open branch not found..."
	echo "# Get a merged branch that matches the name of the current YDBTest MR:"
	curl -s -k "https://gitlab.com/api/v4/projects/7957109/merge_requests?scope=all&state=merged" > ydb_mr.json
	set ydb_branches = `jq -r '.[].source_branch' ydb_mr.json`
	echo "# Merged branches: $ydb_branches"
	if ( " $ydb_branches " =~ " *$ydbtest_branch* " ) set mr_id = `jq -r "$filter" ydb_mr.json`
	if ( $?mr_id ) then
		echo "# MR ID for merged branch is $mr_id"
	endif
else
	set mr_id = `jq -r "$filter" ydb_mr.json`
	echo "# MR ID for open branch is $mr_id"
endif

if ( $ydbtest_branch != "master" && $?mr_id ) then
	# We have a match... grab corresponding YDB MR number
	echo " "
	echo -n "### Building YottaDB branch $ydbtest_branch to match the current branch (MR ID: "
	echo "$mr_id)"
	if ( $?CI_PROJECT_DIR ) then
		# If running in the pipeline, make sure the build output is in a location that can be included in the artifacts
		/usr/library/gtm_test/build_and_install_yottadb.csh V999_R999 master dbg $mr_id >& $CI_PROJECT_DIR/pipeline-test-ydbtest-build.out
	else
		# Otherwise, just use the current directory
		/usr/library/gtm_test/build_and_install_yottadb.csh V999_R999 master dbg $mr_id >& pipeline-test-ydbtest-build.out
	endif
else
	echo "### YottaDB master branch already built"
endif
rm ydb_mr.json
popd >& /dev/null

# Sudo tests rely on the source code for ydbinstall to be in a specific location
ln -s /Distrib/YottaDB /Distrib/YottaDB/V999_R999
echo " "

echo "### Adding YDBTest remote"
if ( ! -f /YDBTest/com/gtmtest.csh ) then
	# Get list of changed files
	# See also: https://forum.gitlab.com/t/ci-cd-pipeline-get-list-of-changed-files/26847.
	set upstream_repo = "https://gitlab.com/YottaDB/DB/YDBTest.git"
	echo "# YDBTest not found: adding $upstream_repo as remote:"
	git remote -v
	git remote | grep -q upstream_repo
	if ($status) git remote add upstream_repo "$upstream_repo"
	git fetch upstream_repo
	set basecommit = `git merge-base HEAD upstream_repo/master`
	setenv filelist `git diff --name-only $basecommit ':(exclude)docker' ':(exclude)com'`
else
	echo "# YDBTest already present at /YDBTest: no fetch needed"
	git config --global --add safe.directory /YDBTest
	set basecommit = `git merge-base HEAD master`
	setenv filelist `git diff --name-only $basecommit | grep -v "docker/"`
endif
echo " "

if ("$filelist" == "") then
	echo "### No tests to run, exiting"
	exit
endif

echo "### Show currently available versions"
ver
echo " "

echo "### Show changed tests"
exec /usr/library/gtm_test/T999/docker/pipeline-run-changed-tests.csh
