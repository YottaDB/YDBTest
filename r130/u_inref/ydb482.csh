#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This tests $ZJOBEXAM with 2 arguments to make sure that the second argument is working correctly.

echo "Testing ZJOBEXAM with no zshow code argument"
$ydb_dist/mumps -r singlearg^zjobexam

echo "Testing ZJOBEXAM with zshow codes *, d, i, g, l, t, r and s"
$ydb_dist/mumps -r zjobexam

echo "Testing ZJOBEXAM with zshow code v"
$ydb_dist/mumps -r vars^zjobexam

echo "Testing ZJOBEXAM with zshow code b"
$ydb_dist/mumps -r breakpoint^zjobexam

echo "Testing ZJOBEXAM with zshow code a"
set save_gtmroutines = "$gtmroutines"
cat > ydb482.m << EOF
	write \$ZJOBEXAM("zje_a.txt","a"),!
	ZSYSTEM "cat zje_a.txt"
	quit
EOF
setenv gtmroutines ".* $ydb_dist"
$ydb_dist/yottadb -run ydb482
setenv gtmroutines "$save_gtmroutines"

echo "Testing ZJOBEXAM with 3 arguments - expecting compilation error"
$ydb_dist/yottadb $gtm_tst/$tst/inref/zjobexamA.m
