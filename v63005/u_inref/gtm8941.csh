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
# Tests LKE recognizes the full keyword for the -CRITICAL qualifier
#
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
echo '# Running the command $ydb_dist/lke show -crit'
$ydb_dist/lke show -crit
echo ""
echo '# Running the command $ydb_dist/lke show -critical'
$ydb_dist/lke show -critical
echo ""
echo '# Running the command $ydb_dist/lke show -nocrit'
$ydb_dist/lke show -nocrit
echo ""
echo '# Running the command $ydb_dist/lke show -nocritical'
$ydb_dist/lke show -nocritical
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
