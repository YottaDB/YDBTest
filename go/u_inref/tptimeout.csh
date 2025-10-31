#################################################################
#								#
# Copyright (c) 2020-2026 YottaDB LLC and/or its subsidiaries.	#
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
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out || \
	echo "# dbcreate failed. Output of dbcreate.out follows" && cat dbcreate.out
#
# Set up the golang environment and sets up our repo
#
# Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $ydbgo_url, $goflags)
source $gtm_tst/com/setupgoenv.csh >& setupgoenv.out || \
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status]:" && cat setupgoenv.out && exit 1

# Build our routine (must be built due to use of cgo).
echo "# Building tptimeout"
$gobuild $gtm_tst/$tst/inref/tptimeout.go >& go_build.log || \
	echo "TEST-E-FAILED : Unable to build tptimeout.go. go_build.log output follows" && cat go_build.log && exit 1
#
# Run tptimeout with our standard input and save the output
#
echo "# Running tptimeout"
`pwd`/tptimeout
#
# Validate DB
#
unsetenv ydb_gbldir
$gtm_tst/com/dbcheck.csh
