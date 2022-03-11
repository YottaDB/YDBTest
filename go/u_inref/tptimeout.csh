#################################################################
#								#
# Copyright (c) 2020-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test drives the golang flavor of the tptimeout test.
#
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
        echo "# dbcreate failed. Output of dbcreate.out follows"
        cat dbcreate.out
endif
#
# Set up the golang environment and sets up our repo
#
source $gtm_tst/com/setupgoenv.csh # Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $go_repo)
set status1 = $status
if ($status1) then
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status1]. Exiting..."
	exit 1
endif

cd go/src
mkdir tptimeout
cd tptimeout
ln -s $gtm_tst/$tst/inref/tptimeout.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link tptimeout.go to current directory ($PWD)"
    exit 1
endif
# Build our routine (must be built due to use of cgo).
echo "# Building tptimeout"
$gobuild >& go_build.log
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build tptimeout.go. go_build.log output follows"
    cat go_build.log
    exit 1
endif
#
# Run tptimeout
#
# Note: We need to set the global directory to an absolute path because we are operating in a subdirectory
# ($tstpath/go/src/tptimeout) where the default test framework assignment of ydb_gbldir
# to a relative path (i.e. mumps.gld) is no longer relevant.
setenv ydb_gbldir $tstpath/mumps.gld
#
# Run tptimeout with our standard input and save the output
#
echo "# Running tptimeout"
`pwd`/tptimeout
#
# Validate DB
#
cd ../../..
unsetenv ydb_gbldir
$gtm_tst/com/dbcheck.csh
