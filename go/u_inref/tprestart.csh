#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
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
echo "in the transaction callback routine, some M code is driven which causes a TP restart. Prior to YDB#619, this"
echo "flavor returned TPRETRY instead."
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
        echo "# dbcreate failed. Output of dbcreate.out follows"
        cat dbcreate.out
endif
#
# Set up the golang environment and sets up our repo
#
source $gtm_tst/com/setupgoenv.csh # Do our Go setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $go_repo)
set status1 = $status
if ($status1) then
	echo "[source $gtm_tst/$tst/u_inref/setupgoenv.csh] failed with status [$status1]. Exiting..."
	exit 1
endif

cd go/src
mkdir tprestart
cd tprestart
ln -s $gtm_tst/$tst/inref/tprestart.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link tprestart.go to current directory ($PWD)"
    exit 1
endif
# Build our routine (must be built due to use of cgo).
echo "# Building tprestart"
$gobuild >& go_build.log
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build tprestart.go. go_build.log output follows."
    cat go_build.log
    exit 1
endif
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
# Note: We need to set the global directory to an absolute path because we are operating in a subdirectory
# ($tstpath/go/src/tprestart) where the default test framework assignment of ydb_gbldir
# to a relative path (i.e. mumps.gld) is no longer relevant.
setenv ydb_gbldir $tstpath/mumps.gld
echo "# Running tprestart"
`pwd`/tprestart Y 0

$gtm_tst/com/dbcheck.csh -extract >>& dbcheck.out
if ($status) then
        echo "# dbcheck failed. Output of dbcheck.out follows"
        cat dbcheck.out
endif
echo "# Done!"
