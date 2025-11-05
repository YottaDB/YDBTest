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

echo "# Test to ensure the mumps compile time warning FALLINTOFLST occurs"
echo "# when expected and that the program still compiles after triggering it."
echo "# Tests the fixes for issue 1142 https://gitlab.com/YottaDB/DB/YDB/-/issues/1142"
echo "# Starting test a, ydb1142a.m."
echo "# previously the compiler would give an error and fail to compile the file"
echo "# Now the compiler should only give 2 FALLINTOFLST warnings and compile"
$gtm_dist/mumps $gtm_tst/$tst/inref/ydb1142a.m
echo
echo "# Starting test b, ydb1142b.m, indented dot edge case."
echo "# This test makes sure that there are no problems in the edge case where"
echo "# a FALLINTOFLST warning is given for a label that is indented."
$gtm_dist/mumps $gtm_tst/$tst/inref/ydb1142b.m
echo
echo "# Starting test c, ydb1142c.m, the one fallthrough case."
echo "# This case makes sure that nothing goes wrong when only one"
echo "# FALLINTOFLST warning is issued."
$gtm_dist/mumps $gtm_tst/$tst/inref/ydb1142c.m
