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
# Test of simulated banking transactions using threaded tp calls
#

echo "# Test of simulated banking transactions using Go Simple API with 10 goroutines in ONE process"

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
	echo "[source $gtm_tst/$tst/u_inref/setupgoenv.csh] failed with status [$status1]. Exiting..."
	exit 1
endif

cd go/src
# test driver
mkdir pseudoBank
cd pseudoBank
ln -s $gtm_tst/$tst/inref/pseudoBank.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link pseudoBank.go to current directory ($PWD)"
    exit 1
endif

# class files
mkdir dataObject
ln -s $gtm_tst/$tst/inref/pseudoBank_*.go dataObject/
if (0 != $status) then
	echo "TEST-E-FAILED : Unable to soft link class files to directoy ($PWD/dataObject)"
	exit 1
endif


# Build our routine (must be built due to use of cgo).
echo "# Building pseudoBank"
$gobuild >& go_build.log
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build pseudoBank.go. go_build.log output follows."
    cat go_build.log
    exit 1
endif
#
# Run pseudoBank
#
# Note: We need to set the global directory to an absolute path because we are operating in a subdirectory
# ($tstpath/go/src/wordfreq) where the default test framework assignment of ydb_gbldir
# to a relative path (i.e. mumps.gld) is no longer relevant.
setenv ydb_gbldir $tstpath/mumps.gld
#
# Run pseudoBank with our standard input and save the output
#
echo "# Running pseudoBank"
`pwd`/pseudoBank

#
# Validate DB
#
cd ../../..
cp $gtm_tst/com/pseudoBankDisp.m .
$gtm_dist/mumps -r pseudoBankDisp
unsetenv ydb_gbldir
$gtm_tst/com/dbcheck.csh
