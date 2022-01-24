#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '--> Test $ZYSQLNULL and $ZYISSQLNULL()'

echo "# Create shared library for alternate collation # 1 (reverse collation) : Needed by a small portion of the tests."
source $gtm_tst/com/cre_coll_sl_reverse.csh 1
echo "# Create shared library for alternate collation # 0 (straight collation)."
echo "# Do this after creating reverse collation shared library so test starts and mostly runs with straight collation."
source $gtm_tst/com/cre_coll_sl_straight.csh 0

# Randomly generated boolean expressions can get as long as even 4K so have a safe record size of 16Kb as they are
# stored in the database (for later debugging in case the test fails). Some boolean expressions can have nested $select
# usages that can go even more than 16Kb in some cases so keep a max record size of 1Mb just to be safe.
$gtm_tst/com/dbcreate.csh mumps -record_size=1048576

# ydb484.m could create deep boolean expressions which can result in the boolexpr nesting depth going more than 4
# (the default allowed depth in the code). Therefore set the below dbg-only env var to a higher value just for this test.
setenv ydb_max_boolexpr_nesting_depth 64
# A few tests in ydb484.m (`view "TRACE":0:$ZYSQLNULL` and `view:tv=1 "TRACE":0:$ZYSQLNULL`) produce different output based
# on the below env var (randomly set by test framework) so set it always since that produces a ZYSQLNULLNOTVALID error
# whereas the unset case does not.
setenv gtm_trace_gbl_name ""
$ydb_dist/mumps -run ydb484 >& ydb484.orig
unsetenv gtm_trace_gbl_name
unsetenv ydb_max_boolexpr_nesting_depth

# ydb484f has hundreds of tests each with a line number printed in the $ZSTATUS output. That can cause test failures
# with a huge diff if even one line gets added to the M program. So try to avoid such failures by replacing
# `ZSTATUS=ydb484f+15^ydb484f` with `ZSTATUS=ydb484f+...^ydb484f`. Similar changes for ydb484g as well.
sed 's/ZSTATUS=ydb484\([fg]\)+[0-9]*\^ydb484/ZSTATUS=ydb484\1+...^ydb484/g' ydb484.orig

echo "# Test of BOOLEXPRTOODEEP error"
echo "  -> Running [yottadb -run boolexprtoodeep^ydb484 > deepbool.m]"
$ydb_dist/mumps -run boolexprtoodeep^ydb484 > deepbool.m
echo "  -> Running [yottadb deepbool.m] : Expect to see a BOOLEXPRTOODEEP error"
$ydb_dist/mumps deepbool.m
echo "  -> Running [yottadb deepbool.m] : Expect to see the same BOOLEXPRTOODEEP error"
$ydb_dist/mumps -run deepbool

$gtm_tst/com/dbcheck.csh

