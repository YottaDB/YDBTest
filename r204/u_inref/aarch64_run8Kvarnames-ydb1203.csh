#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# -------------------------------------------------------------------------------------------------------------'
echo '# Test of M programs on AARCH64 with more than 8Ki distinct local variable names run'
echo '# -------------------------------------------------------------------------------------------------------------'
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

echo "## Test 1: No LVUNDEF when setting 8193 distinct local variable names"
echo "# Run [ydb1203.m] with an argument of 8192 to generate a test routine that sets over 8Ki distinct variable names."
echo "# Expect the LVN 'x8193' to equal the empty string, and no LVUNDEF error to be issued."
echo "# Previously, this would issue an LVUNDEF error and prevent the 'x8193' LVN from being set."
echo "# See the following discussion for source program:https://gitlab.com/YottaDB/DB/YDB/-/work_items/1203#test-case"
$gtm_dist/mumps -run ydb1203 8192 >&! T1.m
$gtm_dist/mumps -run T1
echo

echo "## Test 2: No SIG-11 executing a NEW command after setting 8193 distinct local variable names"
echo "# Run [ydb1203b.m] with an argument of 8192 to generate a test routine that sets over 8Ki distinct variable names, then runs a NEW command."
echo "# Expect the LVN 'x8193' to equal the empty string, and no SIG-11 to occur."
echo "# Previously, this would cause a SIG-11 and prevent the 'x8193' LVN from being set."
echo "# See the following discussion for source program: https://gitlab.com/YottaDB/DB/YDB/-/work_items/1203#test-case"
sed 's/; REPLACE//g' $gtm_tst/$tst/inref/ydb1203.m >&! ydb1203b.m
$gtm_dist/mumps -run ydb1203b 8192 >&! T2.m
$gtm_dist/mumps -run T2
echo

echo "## Test 3: No SIG-4 (illegal opcode) when setting 16385 distinct local variable names"
echo "# Run [ydb1203.m] with an argument of 16384 to generate a test routine that sets over 16Ki distinct variable names."
echo "# Expect the LVN 'x16385' to equal the empty string, and no SIG-4 caused by an illegal opcode to occur."
echo "# Previously, this would cause a SIG-4 due to an illegal opcode and prevent the 'x16385' LVN from being set."
echo "# See the following discussion for source program: https://gitlab.com/YottaDB/DB/YDB/-/work_items/1203#note_3117472158"
$gtm_dist/mumps -run ydb1203 16384 >&! T3.m
$gtm_dist/mumps -run T3

$gtm_tst/com/dbcheck.csh >& dbcheck.out
