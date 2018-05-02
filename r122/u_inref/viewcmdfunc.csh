#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

$gtm_tst/com/dbcreate.csh mumps

echo 'Test of various VIEW commands and $VIEW functions'
foreach label(test1 test2 test3 test4 test5 test6 test7)
	echo " --> Running test ${label}^viewcmdfunc"
	$ydb_dist/mumps -run ${label}^viewcmdfunc
end

$gtm_tst/com/dbcheck.csh
