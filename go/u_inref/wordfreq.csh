#################################################################
#								#
# Copyright (c) 2019-2026 YottaDB LLC and/or its subsidiaries.	#
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
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out || \
	echo "# dbcreate failed. Output of dbcreate.out follows" && cat dbcreate.out
#
# Set up the golang environment and sets up our repo
#
# Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $ydbgo_url, $goflags)
source $gtm_tst/com/setupgoenv.csh >& setupgoenv.out || \
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status]:" && cat setupgoenv.out && exit 1


# Build our routine (must be built due to use of cgo).
echo "# Building wordfreq"
$gobuild $gtm_tst/$tst/inref/wordfreq.go >& go_build.log || \
	echo "TEST-E-FAILED : Unable to build wordfreq.go. go_build.log output follows" && cat go_build.log && exit 1
#
# Run wordfreq with our standard input and save the output
#
echo "# Running wordfreq"
`pwd`/wordfreq < $gtm_tst/$tst/outref/wordfreq_input.txt >& wordfreq.out
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
unsetenv ydb_gbldir
$gtm_tst/com/dbcheck.csh
