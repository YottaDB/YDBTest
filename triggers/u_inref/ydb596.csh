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
echo '# Test that $ZTDELIM is also maintained for KILL/ZKILL/ZTRIG trigger actions'
echo ""

echo "# Creating database"
$gtm_tst/com/dbcreate.csh "mumps"

echo '# Invoking : $ydb_dist/yottadb -run ydb596'
$ydb_dist/yottadb -run ydb596

echo "# Invoking : dbcheck.csh"
$gtm_tst/com/dbcheck.csh
