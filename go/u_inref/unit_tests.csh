#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#

echo "# Run the Go wrapper unit tests; if there is a failure, additional output will cause the test to fail"

# We need to set the global directory to an absolute path because "go test" does a chdir at some point
setenv ydb_gbldir `pwd`/mumps.gld

$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate_log.txt

setenv PKG_CONFIG_PATH $ydb_dist
setenv GOPATH `pwd`/go/
set go_repo="lang.yottadb.com/go/yottadb"

mkdir go

echo "# Fetching $go_repo"
go get -t $go_repo
echo "# Running tests from $go_repo"
go test $go_repo

$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
