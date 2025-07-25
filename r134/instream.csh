#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#---------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------------------------------
# ydb757 [nars]          Test that SET x=$ZYHASH(x) does not issue LVUNDEF error
# ydb775 [nars]          Test that LOCKS obtained inside TSTART/TCOMMIT are correctly released on TRESTART
# ydb782 [nars]          Test ydb_lock_incr_s() call in child process while parent process holds the lock
# ydb772 [sam,ksbhaskar] Utility label $$SRCDIR^%RSEL returns space separated list of source code directories
# ydb785 [estess]        Test that ydb_ci_t() and ydb_cip_t() get text of error message if error occurs in M code
# ydb734 [nars]          Test use cases that came up while fixing code issues identified by enabling address sanitizer
# ydb828 [nars]          Test various code issues identified by fuzz testing
# ydb831 [nars]          Test that $FNUMBER issues LVUNDEF error if input argument is undefined
# ydb555 [nars]          Test that $SELECT with global references in a boolean expression does not GTMASSERT2
# ydb546 [nars]          Test that Nested $SELECT() functions do not GTMASSERT2
# ydb758 [bdw]           Test that %PEEKBYNAME("node_local.max_procs",<region>) works correctly
# ydb557 [nars]          Test that Naked indicator is maintained correctly when $SELECT is used in boolean expression
# ydb840 [nars]          Test that $ZATRANSFORM when first argument is an undefined variable does not SIG-11
# ydb781 [sam,ksbhaskar] ^%RSEL/^%RD include routines in shared library files
# ydb846 [nars]          Test that DSE DUMP -ZWR (or -GLO) does not dump garbled records
# ydb845 [nars]          Test LKE SHOW output is not garbled for long subscripts and not truncated for lots of subscripts
#----------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r134 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""

setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic ydb757"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb775"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb782"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb772"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb785"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb734"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb828"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb831"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb555"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb546"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb758"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb557"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb840"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb781"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb846"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb845"

setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r134 test DONE."
