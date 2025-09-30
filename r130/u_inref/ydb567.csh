#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "dbcreate.csh failed. [cat dbcreate.out] output follows."
	cat dbreate.out
	exit -1
endif

echo '# This test ensures that a MUPIP INTRPT during a hang in a for loop does not'
echo '# result in an assert failure. Previously, this would result in an assert'
echo '# failure when done on a debug build.'
$ydb_dist/yottadb -run test^ydb567
cat ydb567.mjo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "dbcheck.csh failed. [cat dbcheck.out] output follows."
	cat dbcheck.out
	exit -1
endif
