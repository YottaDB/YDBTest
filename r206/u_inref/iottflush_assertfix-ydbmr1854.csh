#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#--------------------------------------------#"
echo '# Test iott_flush() assert fixes in YDB\!1854 #'
echo "#--------------------------------------------#"
echo

cp $gtm_tst/$tst/u_inref/iottflush_assertfix-ydbmr1854.exp .

set tnum = 1
echo "## Test ${tnum}: readline_read_mval() caller"
echo '# Set ydb_readline and run [$ydb_dist/yottadb -direct]'
echo '# Expect a blank prompt and no assert failure. Prior to the YDB\!1854 (commit d7485682) changes,'
echo '# this would cause an assert failure.'
setenv ydb_readline 1
expect -d iottflush_assertfix-ydbmr1854.exp T${tnum} >&! T${tnum}.exp.out
cat T${tnum}.out
echo

set tnum = 2
echo "## Test ${tnum}: iott_rdone() caller"
echo '# Run [$ydb_dist/yottadb -run %XCMD '"'read *x' > x.out]"
echo '# Expect the output "X" and no assert failure. Prior to the YDB\!1854 (commit d7485682) changes,'
echo '# this would cause an assert failure.'
unsetenv ydb_readline
expect -d iottflush_assertfix-ydbmr1854.exp T${tnum} >&! T${tnum}.exp.out
cat T${tnum}.out
echo
