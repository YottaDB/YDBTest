#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# ------------------------------------------------------------------------------------'
echo '# Test that $SELECT with global references in a boolean expression does not GTMASSERT2'
echo '# ------------------------------------------------------------------------------------'

$gtm_tst/com/dbcreate.csh mumps
$ydb_dist/yottadb -run ydb555
$gtm_tst/com/dbcheck.csh

