#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;'
The following subtest tests that a GT.M v7.1-001 regression is not included in the YottaDB codebase.
For more information see the discussion at: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/658#note_2332948688.
CAT_EOF
echo

setenv ydb_prompt 'GTM>'	# So can run the test under GTM or YDB
setenv ydb_msgprefix "GTM"	# So can run the test under GTM or YDB

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

echo "# Run test routine: Expect NUMOFLOW error"
echo "# Previously, in V71001, there was a regression such that this routine would incorrectly result in either:"
echo "#		1. dbg builds: %GTM-F-ASSERT, Assert failed in sr_port/gvcst_incr.c line 40 for expression (MV_IS_NUMERIC(increment))"
echo "#		2. pro builds: no error"
$gtm_dist/mumps -run numoflowreg

$gtm_tst/com/dbcheck.csh >& dbcheck.out
