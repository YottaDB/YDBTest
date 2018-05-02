#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test that BLKTOODEEP error is not issued if -NOWARNING is specified at compile time"
echo ""

cp $gtm_tst/$tst/inref/blktoodeep.m .

echo "# First test MUMPS blktoodeep.m : Expect EXPR and BLKTOODEEP warnings"
echo "---------------------------------------------------------------------"
$ydb_dist/mumps blktoodeep.m
echo ""

echo "# Now test MUMPS -nowarning blktoodeep.m : Expect neither EXPR nor BLKTOODEEP warnings"
echo "--------------------------------------------------------------------------------------"
$ydb_dist/mumps -nowarning blktoodeep.m
echo ""

echo "# End of test"
