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

echo '---------------------------------------------------------------------------------------------------------------'
echo '######## Test use cases that came up while fixing code issues identified by enabling address sanitizer ########'
echo '---------------------------------------------------------------------------------------------------------------'

# The below test was constructed based on analyzing an address sanitizer buffer overflow issue in the r120/ydbdist subtest
# In that test we had a [yottadb] command issued and an empty string supplied when the "What file" prompt showed up.
# After fixing that code issue, I tried out a slightly different command which was [yottadb .] and that assert failed
# in zl_cmd_qlf.c. So fixed that in the code and came up with some slightly related tests below.
echo '# Running : [yottadb .] : Expecting to not see an assert failure in zl_cmd_qlf.c'
echo '# Also running various related test cases : Expecting errors but no assert failures'
foreach param (. .. ...)
	echo "## Running : [yottadb $param]"
	$ydb_dist/yottadb $param
	echo "## Running : [yottadb ${param}abcd]"
	$ydb_dist/yottadb ${param}abcd
end

echo '# Running : [yottadb -nameofrtn=GTM8068 $gtm_tst/$tst/inref/] : Expecting to not see an assert failure in zl_cmd_qlf.c'
$ydb_dist/yottadb -nameofrtn=GTM8068 $gtm_tst/$tst/inref/

