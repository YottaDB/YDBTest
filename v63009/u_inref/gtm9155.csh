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

cat >> test1.m << xx
	set false=0
	if (0'&(\$select((false?1A):0,(0'?1A):(false!0),\$select(false:0,false:1,false:1,1:1):1)))
xx

cat >> test2.m << xx
	set \$etrap="zwrite \$zstatus  halt"
	if 0
	set false=0,true=1,result=0&\$select(false:0,\$test?1A:1=0,\$select(true:1):1) zwrite result
xx

cat >> test3.m << xx
	set \$etrap="zwrite \$zstatus  halt"
	set false=0,result=0&\$select(false:1&0,false:\$select(false:0,1:0),1:1) zwrite result
xx

cat >> test4.m << xx
	set \$etrap="zwrite \$zstatus  halt"
	set false=0,result=0&(\$select(false?1A:0,0'?1A:false!0,\$select(false:1,1:1):1)) zwrite result
xx

cat >> test5.m << xx
	set \$etrap="zwrite \$zstatus  halt"
	set false=0,result=0&(\$select(false?1A:0,0'?1A:false!0,\$select(false:\$\$extselect(1,1,0),1:1):1)) zwrite result
	quit
extselect(a,b,c)
	quit \$select(true:a&b,false:b&c,true:c&a,1:1)
xx

cat >> test6.m << xx
	set \$etrap="zwrite \$zstatus  halt"
	set false=0,result=0&(\$select(false?1A:0,0'?1A:false!0,\$select(false:\$\$extselect(0,1,1),1:1):1)) zwrite result
	quit
extselect(a,b,c)
	quit \$select(true:a&b,false:b&c,true:c&a,1:1)
xx

cat >> test7.m << xx
	set \$etrap="zwrite \$zstatus  halt"
	set false=0,result=0&\$select(false:1&0,false:\$select(false:0,1:\$\$extselect(1,0,1)),1:1) zwrite result
extselect(a,b,c)
	quit \$select(true:a&b,false:b&c,true:c&a,1:1)
xx

echo "running test 1"
$ydb_dist/yottadb -run test1
echo "running test 2"
$ydb_dist/yottadb -run test2
echo "running test 3"
$ydb_dist/yottadb -run test3
echo "running test 4"
$ydb_dist/yottadb -run test4
echo "running test 5"
$ydb_dist/yottadb -run test5
echo "running test 6"
$ydb_dist/yottadb -run test6
echo "running test 7"
$ydb_dist/yottadb -run test7
