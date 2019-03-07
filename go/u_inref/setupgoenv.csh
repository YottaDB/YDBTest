#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This script is meant to be source'd by golang tests to both setup the golang environment and
# fetch the yottadb package into it before building/running the specific golang test.
#
set tstpath = `pwd`
setenv PKG_CONFIG_PATH $ydb_dist
setenv GOPATH $tstpath/go/
set go_repo="lang.yottadb.com/go/yottadb"
mkdir go

# Retrieve yottadb package from the repository
echo "# Running : go get -t $go_repo"
go get -v -x -t $go_repo |& $tst_awk '{print strftime("%T"),":",$0}' >& go_get.log
set status1 = $status
if ($status1) then
	echo "TEST-E-FAILED : [go get -t $go_repo] returned failure status of $status1"
	exit 1
endif

cd go/src/$go_repo
if ($?ydb_test_go_repo_dir) then
	# If env var "ydb_test_go_repo_dir" is defined, use this as the path of the go repo instead of the go repo on gitlab.
	git remote add tmp $ydb_test_go_repo_dir
	set status1 = $status
	if ($status1) then
		echo "TEST-E-FAILED : [git remote add tmp $ydb_test_go_repo_dir] returned failure status of $status1"
		exit 1
	endif
	git fetch tmp >& git_fetch.log
	set status1 = $status
	if ($status1) then
		echo "TEST-E-FAILED : [git fetch tmp] returned failure status of $status1"
		exit 1
	endif
	if ($?ydb_test_go_repo_branch) then
		# If env var "ydb_test_go_repo_branch" is defined, use that as the branch
		git checkout -b tmp tmp/$ydb_test_go_repo_branch >& git_checkout.log
		set status1 = $status
		if ($status1) then
			echo "TEST-E-FAILED : [git checkout -b tmp tmp/$ydb_test_go_repo_branch] returned failure status of $status1"
			exit 1
		endif
	else
		# Else use "develop" branch as the default ("master" branch is latest released code, not latest developed code)
		git checkout -b tmp tmp/develop >& git_checkout.log
		set status1 = $status
		if ($status1) then
			echo "TEST-E-FAILED : [git checkout -b tmp tmp/develop] returned failure status of $status1"
			exit 1
		endif
	endif
else
	# We used the go repo on gitlab. By default, "go get" would checkout the "master" branch.
	# But we want to checkout the "develop" branch.
	git checkout develop >& git_checkout.log
	set status1 = $status
	if ($status1) then
		echo "TEST-E-FAILED : [git checkout develop] returned failure status of $status1"
		exit 1
	endif
endif
cd -

exit 0
