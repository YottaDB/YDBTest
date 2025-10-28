#################################################################
#								#
# Copyright (c) 2022-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# ---------------------------------------------------------------------------------------'
echo '# Test that Nested $SELECT() functions do not issue incorrect GTMASSERT2 or LVUNDEF error'
echo '# ---------------------------------------------------------------------------------------'

$gtm_tst/com/dbcreate.csh mumps
@ num = 1

while ($num < 10)
	$ydb_dist/yottadb -run test$num^ydb546
	@ num = $num + 1
end
$gtm_tst/com/dbcheck.csh

