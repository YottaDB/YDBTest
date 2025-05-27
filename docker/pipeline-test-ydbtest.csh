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

# See if we need to build a branch version of YottaDB to match the current branch
pushd /usr/library/gtm_test/T999

# https://forum.gitlab.com/t/why-i-cant-get-the-branch-name/72462/6
# Gitlab detaches the git tree (i.e. a checkout creates a detached tree, so rev-parse of HEAD just returns HEAD)
# The rev-parse way is left in order to be able to test this pipeline locally.
if ( $?CI_COMMIT_BRANCH ) then
	set ydbtest_branch = $CI_COMMIT_BRANCH
else
	set ydbtest_branch = `git rev-parse --abbrev-ref HEAD`
endif

echo "ydbtest_branch: $ydbtest_branch"
curl -s -k "https://gitlab.com/api/v4/projects/7957109/merge_requests?scope=all&state=opened" > ydb_open_mrs.json
set ydb_branches = `jq -r '.[].source_branch' ydb_open_mrs.json`
echo "ydb_branches: $ydb_branches"

if ( $ydbtest_branch != "master" && " $ydb_branches " =~ " *$ydbtest_branch* " ) then
	# We have a match... grab corresponding YDB MR number
	echo "Building YottaDB branch $ydbtest_branch"
	set filter = ".[] | select(.source_branch == \"$ydbtest_branch\") | .iid"
	set mr_id = `jq -r "$filter" ydb_open_mrs.json`
	/usr/library/gtm_test/build_and_install_yottadb.csh V999_R999 master dbg $mr_id
endif
rm ydb_open_mrs.json
popd

# Sudo tests rely on the source code for ydbinstall to be in a specific location
ln -s /Distrib/YottaDB /Distrib/YottaDB/V999_R999

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
	setenv filelist `git diff --name-only $basecommit`
else
	# Test system passed in /YDBTest
	git config --global --add safe.directory /YDBTest
	set basecommit = `git merge-base HEAD master`
	setenv filelist `git diff --name-only $basecommit`
endif

echo "Currently available versions: "
ver

exec /usr/library/gtm_test/T999/docker/pipeline-run-changed-tests.csh
