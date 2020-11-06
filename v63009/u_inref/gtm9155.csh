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

echo "# This tests nested select statements, some of them including extrinsics, that caused assert failures"
echo "# on upstream versions V6.3-001 to V6.3-008. This verifies that the assert failures are gone and these"
echo "# particular nested selects work correctly."

$echoline
echo "# running test 1"
$ydb_dist/yottadb -run test1^gtm9155
$echoline
echo "# running test 2"
$ydb_dist/yottadb -run test2^gtm9155
$echoline
echo "# running test 3"
$ydb_dist/yottadb -run test3^gtm9155
$echoline
echo "# running test 4"
$ydb_dist/yottadb -run test4^gtm9155
$echoline
echo "# running test 5"
$ydb_dist/yottadb -run test5^gtm9155
$echoline
echo "# running test 6"
$ydb_dist/yottadb -run test6^gtm9155
$echoline
echo "# running test 7"
$ydb_dist/yottadb -run test7^gtm9155
