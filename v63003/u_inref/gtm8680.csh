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
#
# Tests YDB does not experience significant slowdown with large number locks and/or processes
#
$gtm_tst/com/dbcreate.csh mumps 1 -lock_space=60000>& a.out
echo "# Running test with 1 process that creates 100000 lock names"
echo "# Locking ^a in child function and attempting to lock ^a(i) in parent"
setenv proc 1
$ydb_dist/mumps -run manylocks^gtm8680
echo ""
echo "# Running test with 100 processes, each holding 1000 locks"
echo "# Locking ^a(1)-^a(100000) in child processes, attempting to lock ^a(i) in parent"
setenv proc 0
$ydb_dist/mumps -run manylocks^gtm8680
echo ""
echo "# Test maximum lock space supported is increased from 65536 to 262144"
echo ""

$MUPIP set -lock=65536 -region DEFAULT
$MUPIP set -lock=65537 -region DEFAULT
$MUPIP set -lock=262144 -region DEFAULT
$MUPIP set -lock=262145 -region DEFAULT
$gtm_tst/com/dbcheck.csh >& b.out
