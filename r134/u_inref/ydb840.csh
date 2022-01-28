#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo ""
echo "------------------------------------------------------------"
echo '# Test that $ZATRANSFORM when first argument is an undefined variable does not SIG-11'
echo '# Only expect graceful LVUNDEF runtime error'
echo "------------------------------------------------------------"
echo "# Try all test cases using [yottadb -run]"
echo "------------------------------------------------------------"
@ num = 1
while ($num < 3)
	$ydb_dist/yottadb -run test$num^ydb840
	@ num = $num + 1
end
echo "------------------------------------------------------------"
echo "# Try all test cases using [yottadb -direct]"
echo "------------------------------------------------------------"
$grep -Ewi "write" $gtm_tst/$tst/inref/ydb840.m > ydb840direct.m
cat ydb840direct.m | $ydb_dist/yottadb -direct

