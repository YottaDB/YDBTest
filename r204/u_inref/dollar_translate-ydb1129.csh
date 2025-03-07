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

echo '# -------------------------------------------------------------------------------------------------------------'
echo '# Test that $TRANSLATE in UTF-8 mode does not fail with GTMASSERT2 if search string is more than 256 chars long'
echo '# Also test $TRANSLATE functionality in general for both M and UTF-8 mode'
echo '# -------------------------------------------------------------------------------------------------------------'

echo "# Create database"
# Create database with a big record size since ydb1129.m tries to store potentially long strings in globals in case of a failure
$gtm_tst/com/dbcreate.csh mumps -record_size=16384 >& dbcreate.out

echo "# Run [mumps -run ydb1129]."
echo '# This will generate random $TRANSLATE invocations.'
echo '# This used to almost always fail with a GTMASSERT2 fatal error before YDB#1129 was fixed.'
echo '# After YDB#1129 was fixed, this issues no errors. We expect to see PASS below.'
$gtm_dist/mumps -run ydb1129
echo

echo '# -------------------------------------------------------------------------------------------------------------'
echo '# Run tests from https://gitlab.com/YottaDB/DB/YDB/-/issues/1129#description'
echo '# -------------------------------------------------------------------------------------------------------------'
echo '# Invoking [mumps -run testorig1^ydb1129]'
echo '# This used to previously fail with a GTMASSERT2 error'
echo '# We now do not expect any error or output below'
$gtm_dist/mumps -run testorig1^ydb1129
echo

echo '# Invoking [mumps -run testorig2^ydb1129]'
echo '# This used to previously fail with a GTMASSERT2 error'
echo '# We now do not expect any error or output below'
$gtm_dist/mumps -run testorig2^ydb1129
echo

echo '# Invoking [mumps -run testorig3^ydb1129]'
echo '# This used to previously fail with a GTMASSERT2 error'
echo '# We now do not expect any error or output below'
$gtm_dist/mumps -run testorig3^ydb1129
echo

echo "# Run [dbcheck.csh]"
$gtm_tst/com/dbcheck.csh >>& dbcreate.out
