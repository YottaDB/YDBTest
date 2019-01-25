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
# This test verifies that the tools to generate glue code work
#
# Use -gld_has_db_fullpath to ensure gld is created with full paths pointing to the database file
# (see comment before "setenv ydb_gbldir" done below for why).
if ($?test_replic) then
	# Need to use MSR framework whenever -gld_has_db_fullpath is in use (non-MSR replication does not work currently)
	$MULTISITE_REPLIC_PREPARE 2	# Create two instances INST1 (primary side) and INST2 (secondary side)
endif
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
        echo "# dbcreate failed. Output of dbcreate.out follows"
        cat dbcreate.out
endif
if ($?test_replic) then
    $MSR START INST1 INST2 # Start replication servers
endif
#
# Set up the golang environment and sets up our repo
#
source $gtm_tst/$tst/u_inref/setupgoenv.csh # Do our golang setup (sets $tstpath)
ln -s $gtm_tst/$tst/inref/hellotp.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link go source file"
    exit 1
endif
echo "# Installing ydb-dev-tools"
go get $go_repo/cmd/ydb-dev-tools
if ($status) then
    echo "TEST-E-FAILED: go get -t $gorepo/cmd/ydb-dev-tools returned failure status of $status"
    exit 1
endif
setenv PATH "$GOPATH/bin:$PATH"

echo "# Generating glue code"
ydb-dev-tools generate -pkg main -func MyGoCallback
echo "# Compiling Go program"
go build -o hello

echo "# Running Go program"
./hello

echo "# Verifying that a global was set"
$gtm_dist/mumps -r %XCMD "WRITE ^hello"

$gtm_tst/com/dbcheck.csh -extract >>& dbcheck.out
if ($status) then
        echo "# dbcheck failed. Output of dbcheck.out follows"
        cat dbcheck.out
endif

echo "# Done!"
