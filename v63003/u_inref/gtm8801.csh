#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Tests ^%YGBLSTAT works on a cmake build
#
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
echo "# Running %YGBLSTAT"
$ydb_dist/mumps -run %YGBLSTAT
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
