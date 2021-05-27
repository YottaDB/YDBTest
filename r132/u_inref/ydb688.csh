#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo '# ---------------------------------------------------------------------------------------------'
echo '# Test ZWRITE with pattern match no longer fails with LVUNDEF if DB has null subscripts enabled'
echo '# ---------------------------------------------------------------------------------------------'
echo "# Creating database"
$gtm_tst/com/dbcreate.csh mumps 1 -stdnull -null_subscripts=TRUE
$ydb_dist/yottadb -dir << EOF
SET ^x(1,"a",1)=""
ZWRITE ^x(1,:,?1N)
EOF
