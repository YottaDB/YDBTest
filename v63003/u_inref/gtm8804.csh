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

echo "# Creating database"
$gtm_tst/com/dbcreate.csh mumps 1 >>& db_log.txt

echo "# Producing ZSHOW for g, l and t"
$ydb_dist/mumps -run gtm8804

echo "# Shutting down database"
$gtm_tst/com/dbcheck.csh >& db_log.txt

