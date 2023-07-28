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
$gtm_tst/com/dbcheck.csh
