#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
setenv gtm_test_use_V6_DBs 0 # Prevent random V6 version from creating DB with different lock space size defaults
$echoline
echo "YDB#721 : Test that LKE SHOW does not insert a line feed after a lock reference longer than 24 chars"
$echoline
echo "# Running : dbcreate.csh mumps"
$gtm_tst/com/dbcreate.csh mumps
echo "# Running : yottadb -run ydb721 : LKE SHOW output should have each lock name in just one line (not multiple lines)"
$ydb_dist/yottadb -run ydb721
echo "# Running : dbcheck.csh mumps"
$gtm_tst/com/dbcheck.csh

