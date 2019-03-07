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
# This test/demo drives the golang flavor of the word frequency test.
#
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
        echo "# dbcreate failed. Output of dbcreate.out follows"
        cat dbcreate.out
endif
#
# Set up the golang environment and sets up our repo
#
source $gtm_tst/$tst/u_inref/setupgoenv.csh # Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $go_repo)
set status1 = $status
if ($status1) then
	echo "[source $gtm_tst/$tst/u_inref/setupgoenv.csh] failed with status [$status1]. Exiting..."
	exit 1
endif

cd go/src
mkdir wordfreq
cd wordfreq
ln -s $gtm_tst/$tst/inref/wordfreq.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link wordfreq.go to current directory ($PWD)"
    exit 1
endif
# Build our routine (must be built due to use of cgo).
echo "# Building wordfreq"
go build
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build wordfreq.go"
    exit 1
endif
#
# Run wordfreq
#
# Note: We need to set the global directory to an absolute path because we are operating in a subdirectory
# ($tstpath/go/src/wordfreq) where the default test framework assignment of ydb_gbldir
# to a relative path (i.e. mumps.gld) is no longer relevant.
setenv ydb_gbldir $tstpath/mumps.gld
#
# Run wordfreq with our standard input and save the output
#
echo "# Running wordfreq"
wordfreq < $gtm_tst/$tst/outref/wordfreq_input.txt >& wordfreq.out
echo "# Running diff with expected output"
diff $gtm_tst/$tst/outref/wordfreq_output.txt wordfreq.out
if ($status) then
	echo "WORDFREQ-E-FAIL : diff failed"
else
	echo "  --> PASS from wordfreq"
endif
#
# Validate DB
#
cd ../../..
unsetenv ydb_gbldir
$gtm_tst/com/dbcheck.csh
