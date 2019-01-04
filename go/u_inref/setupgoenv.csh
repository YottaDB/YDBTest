#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.	#
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
go get -t $go_repo
if ($status) then
	echo "TEST-E-FAILED : go get -t $go_repo returned failure status of $status"
	exit 1
endif
