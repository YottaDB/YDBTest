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
echo "# This test verifies that, using the SimpleThreadAPI (via Go), if a TP restart is induced via a SimpleThreadAPI"
echo "# call, it returns YDB_TP_RESTART (error text is a fast-path 'TPRESTART'). But we also want this return code if,"
echo "# in the transaction callback routine, some M code is driven which causes a TP restart. Prior to YDB#619, this"
echo "# flavor returned TPRETRY instead."
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out || \
	echo "# dbcreate failed. Output of dbcreate.out follows" && cat dbcreate.out
#
# Set up the golang environment and sets up our repo
#
# Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $ydbgo_url, $goflags)
source $gtm_tst/com/setupgoenv.csh >& setupgoenv.out || \
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status]:" && cat setupgoenv.out && exit 1

# Build our routine (must be built due to use of cgo).
echo "# Building tprestart"
$gobuild $gtm_tst/$tst/inref/tprestart.go >& go_build.log || \
	echo "TEST-E-FAILED : Unable to build tprestart.go. go_build.log output follows." && cat go_build.log && exit 1
# Create our micro M routine we want to call
cat >> ZNEWTEST.m << EOF
RUN()
	N x
	S x=\$I(^ZTESTREAL)
	Q
EOF
# This test uses a callin table so create and set that up.
setenv ydb_ci `pwd`/tprestart.ci
cat >> $ydb_ci <<EOF
Run : void RUN^ZNEWTEST()
EOF
#
# Run it..
#
echo "# Running tprestart"
`pwd`/tprestart Y 0

$gtm_tst/com/dbcheck.csh -extract >>& dbcheck.out || \
	echo "# dbcheck failed. Output of dbcheck.out follows" && cat dbcheck.out
echo "# Done!"
