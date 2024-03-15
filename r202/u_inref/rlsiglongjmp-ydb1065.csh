#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Multiple signals to a process in readline mode causes loss of stack."
echo "# This is a whitebox test that only runs in debug mode."
echo "# The following expect script will fail with cores on the whitebox test WBTEST_YDB_RLSIGLONGJMP"
echo "# when run without the YDB#1065 fixes."

setenv ydb_readline 1
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 206 # WBTEST_YDB_RLSIGLONGJMP

$gtm_tst/com/dbcreate.csh mumps

(expect -d $gtm_tst/$tst/inref/rlsiglongjmp-ydb1065.exp > expect.out) >& expect.dbg
perl $gtm_tst/com/expectsanitize.pl expect.out > expect_sanitized.out
cat expect_sanitized.out

$gtm_tst/com/dbcheck.csh
