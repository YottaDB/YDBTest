#################################################################
#								#
# Copyright (c) 2021-2026 YottaDB LLC and/or its subsidiaries.	#
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
# Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $ydbgo_url, $goflags)
source $gtm_tst/com/setupgoenv.csh >& setupgoenv.out || \
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status]:" && cat setupgoenv.out && exit 1

# Build our routine (must be built due to use of cgo).
echo "# Building ydb785"
$gobuild $gtm_tst/$tst/inref/ydb785.go >& go_build.log || \
	echo "TEST-E-FAILED : Unable to build ydb785.go. go_build.log output follows" && cat go_build.log && exit 1
ln -s $gtm_tst/$tst/inref/ydb785.m .
# Create the call table
setenv ydb_ci ./ydb785.ci
cat > $ydb_ci << EOF
GimeLVUNDEF : void entry^ydb785()
EOF
#
# Run ydb785
#
echo "Running ydb785"
`pwd`/ydb785
echo
echo "Test ydb785 complete"
