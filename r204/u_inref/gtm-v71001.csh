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

echo "#---------------------------------------------------------------------------"
echo "# Test few gvn usages in boolean expressions that failed during fuzz testing"
echo "# These used to assert fail and/or SIG-11 before GT.M V7.1-001 got merged"
echo "# Not sure what GT.M release note fixed this longstanding issue"
echo "# See https://gitlab.com/YottaDB/DB/YDB/-/issues/1018#note_2289799513 for actual test cases"
echo "#---------------------------------------------------------------------------"
echo ''

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif
echo ""

echo "## Test case 1 : Original fuzz testing failure"
echo "## Expect LVUNDEF error (not SIG-11 or assert failure)"
$gtm_dist/mumps -run %XCMD 'S VCOMP=VCOMP_$NEXT(^V1(-1))_$N(^V1(1))_$N(^V1(10))_$I(^V1(1&-1))_$N(^V1(10,10,10))'

echo "## Test case 2 : Simplest case that failed like the previous test case"
echo "## Expect GVUNDEF error (not SIG-11 or assert failure)"
$gtm_dist/mumps -run %XCMD 'write $incr(^x(1&1))_^x'

echo '## Test case 3 : Slightly fancy example using a naked indicator in the second argument to $incr.'
echo "## Expect GVNAKED error (not SIG-11 or assert failure)"
set backslash_quote
$gtm_dist/mumps -run %XCMD 'write $incr(^V(-234.344\!23.44),^(2,3))'

echo "# Run dbcheck.csh"
$gtm_tst/com/dbcheck.csh
