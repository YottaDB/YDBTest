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

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 406 # WBTEST_YDB_RLSIGLONGJMP

$gtm_tst/com/dbcreate.csh mumps

(expect -d $gtm_tst/$tst/inref/rlsiglongjmp-ydb1065.exp > expect.out) >& expect.dbg
perl $gtm_tst/com/expectsanitize.pl expect.out > expect_sanitized.out

# We occasionally see an empty line in the output. Originally we thought it was a libreadline 7 vs 8 issue
# But we have since seen failures of this kind even on libreadline 8 systems (Ubuntu 24.04) and so suspect
# it is a test timing issue. Instead of spending time analyzing/fixing it, we work around it by filtering all
# empty lines in the output thereby removing any non-deterministic output and letting this subtest run on all
# distributions. See https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1919#note_1903056143 for more details.
grep -v '^$' expect_sanitized.out

$gtm_tst/com/dbcheck.csh
