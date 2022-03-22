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
echo '# ---------------------------------------------------------------------------------------'
echo '# Test that Nested $SELECT() functions do not issue incorrect GTMASSERT2 or LVUNDEF error'
echo '# ---------------------------------------------------------------------------------------'

$gtm_tst/com/dbcreate.csh mumps
@ num = 1

# We set $ydb_max_boolexpr_nesting_depth to 8 to avoid a rare failure where test9 can result
# in an assert failure on a dbg build due to excessive nesting of the boolean expression
setenv ydb_max_boolexpr_nesting_depth 8
while ($num < 10)
	$ydb_dist/yottadb -run test$num^ydb546
	@ num = $num + 1
end
$gtm_tst/com/dbcheck.csh

