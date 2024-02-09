#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out

# display lines starting with '#' or READLINE or ASSERT error
(ydb88_exec_test.csh $0 grep '^\#\|READLINE\|ASSERT' >! expect.out) >&! expect.dbg
cat expect.out

$gtm_tst/com/dbcheck.csh >& dbcheck.out
