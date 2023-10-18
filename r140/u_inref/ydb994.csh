#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps

echo '#####################################################################'
echo '######## Test various code issues identified by fuzz testing ########'
echo '#####################################################################'

echo ""
echo "------------------------------------------------------------"
echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/994#note_1385299862'
echo '# Test GVSUBOFLOW error'
echo '# Prior to YDB@cb4697bf, this test failed with an assert/SIG-11'
echo '# Expecting only GVSUBOFLOW errors in below output in each invocation'
echo "------------------------------------------------------------"
set base = "ydb994gvsuboflow"
echo "# Try $base.m using [yottadb -run]"
$ydb_dist/yottadb -run $base

echo ""
echo "------------------------------------------------------------"
echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/994#note_1607739778'
echo '# Prior to merging GT.M V7.0-001, this test failed with a GTMASSERT in cache_cleanup.c'
echo '# Expecting only %YDB-E-INVCMD and %YDB-W-ZTIMEOUT errors in below output'
echo "------------------------------------------------------------"
set base = "ydb994zhelpgtmassert"
cp $gtm_tst/$tst/inref/$base.m .
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
# Need to use %XCMD to set $ztrap to "incrtrap" so we continue execution of full M program inspite of errors.
$ydb_dist/yottadb -run %XCMD 'set $ztrap="goto incrtrap^incrtrap" do ^'$base

echo ""
echo "------------------------------------------------------------"
echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/994#note_1609142435'
echo '# Prior to r1.36, this test failed with an assert in trans_code_cleanup.c'
echo '# Expecting only %YDB-E-FILENOTFND and %YDB-W-ZLINKFILE errors in below output'
echo "------------------------------------------------------------"
set base = "ydb994transcodecleanup"
cp $gtm_tst/$tst/inref/$base.m .
echo "# Try $base.m using [yottadb -direct]"
rm -f foo.m foo.o
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
# Need to use %XCMD to set $ztrap to "incrtrap" so we continue execution of full M program inspite of errors.
rm -f foo.m foo.o
$ydb_dist/yottadb -run %XCMD 'set $ztrap="goto incrtrap^incrtrap" do ^'$base

echo ""
echo "------------------------------------------------------------"
echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/994#note_1609147517'
echo '# At some prior point in time, this test failed with an assert in trans_code_cleanup.c'
echo '# Expecting only %YDB-E-INVCMD error (only in [yottadb -direct] invocation) in below output'
echo "------------------------------------------------------------"
set base = "ydb994transcodecleanup2"
cp $gtm_tst/$tst/inref/$base.m .
echo "# Try $base.m using [yottadb -direct]"
cat $base.m | $ydb_dist/yottadb -direct
echo "# Try $base.m using [yottadb -run]"
# Need to use %XCMD to set $ztrap to "incrtrap" so we continue execution of full M program inspite of errors.
$ydb_dist/yottadb -run %XCMD 'set $ztrap="goto incrtrap^incrtrap" do ^'$base

echo ""
$gtm_tst/com/dbcheck.csh
