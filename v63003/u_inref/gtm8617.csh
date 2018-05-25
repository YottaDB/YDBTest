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
# Case for each functionality described in the release note
#

echo "# Null subscript set to never"
$gtm_tst/com/dbcreate.csh mumps 1 >>& db.txt
$ydb_dist/mupip set -region DEFAULT -N=never
$gtm_tst/com/dbcheck.csh >& db.txt

echo "# Null subscript set to existing"
$gtm_tst/com/dbcreate.csh mumps 1 >>& db.txt
$ydb_dist/mupip set -region DEFAULT -N=existing
$gtm_tst/com/dbcheck.csh >& db.txt

echo "# Null subscript set to always"
$gtm_tst/com/dbcreate.csh mumps 1 >>& db.txt
$ydb_dist/mupip set -region DEFAULT -N=always
$gtm_tst/com/dbcheck.csh >& db.txt

echo "# Null collation set to GT.M"
$gtm_tst/com/dbcreate.csh mumps 1 >>& db.txt
$ydb_dist/mupip set -region DEFAULT -std
$gtm_tst/com/dbcheck.csh >& db.txt

echo "# Null collation set to M"
$gtm_tst/com/dbcreate.csh mumps 1 >>& db.txt
$ydb_dist/mupip set -region DEFAULT -nostd
$gtm_tst/com/dbcheck.csh >& db.txt











