#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "A regression was introduced in GT.M V6.3-009 that produced incorrect"
echo "output on calls to %HO when the input was between DE0B6B3A7640001"
echo "and FFFFFFFFFFFFFFF (1000000000000000001 to 1152921504606846975 in decimal)."
echo "While this shows up as a rare failure for v63005/gtm5574, this test"
echo "is intended to specifically test for this regression by generating only"
echo "numbers in the range where %HO returns incorrect results. The test generates"
echo "10 random numbers in this range because some numbers, particularly those"
echo "where the final digit of the number is a 0, may be converted to the correct"
echo "octal number."

$ydb_dist/yottadb -run ydb652
