#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test verifies that the Go wrapper can receive the text of errors that occur while in M mode. This test
# fails with a version prior to r1.34.
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
mkdir ydb785
cd ydb785
ln -s $gtm_tst/$tst/inref/ydb785.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link ydb785.go to current directory ($PWD)"
    exit 1
endif
# Build our routine (must be built due to use of cgo).
echo "# Building ydb785"
$gobuild >& go_build.log
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build ydb785.go. go_build.log output follows"
    cat go_build.log
    exit 1
endif
# Need a subdir to put our M routine in or else Go has trouble with it.
mkdir mroutines
ln -s $gtm_tst/$tst/inref/ydb785.m mroutines/.
# Create the call table
setenv ydb_ci ./ydb785.ci
cat > $ydb_ci << EOF
GimeLVUNDEF : void entry^ydb785()
EOF
# Add this directory to $gtmroutines
setenv gtmroutines "$gtmroutines ./mroutines"
#
# Run ydb785
#
echo "Running ydb785"
`pwd`/ydb785
echo
echo "Test ydb785 complete"
