#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#----------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------
# rlsiglongjmp-ydb1065				[sam]	  Multiple signals to a process in readline mode causes loss of stack
# mupip_verbose-ydb1060				[pooh]	  Test functionality of MUPIP BACKUP, MUPIP FREEZE and MUPIP INTEG with option -DBG and -VERBOSE
# zshow_tt_host_conv-ydb1068			[pooh]	  Test ZSHOW "D" output for TTSYNC, NOTTSYNC, HOSTSYNC, NOHOSTSYNC, CONVERT and NOCONVERT
# empty_socket_assert-ydb1076			[pooh]	  Test if empty host string in socket connection parameter causing assertion failure
# xcretnull-ydb1007				[berwyn]  Ensure that external calls that return invalid values produce errors
# relinkctl_crash-ydb1083			[nars]	  Test that relinkctl file latch is salvaged in 1 second (not 1 minute) after crash
# max_truncate_to_error-ydb1048			[david]	  Test that command utilities with input that is too long, return errors, rather than truncate
# bool_expr_equnul-ydb777			[nars]	  Test that s="" and s'="" in simple boolean expressions are fast
# bad_query_res_on_mapped_sub_lvl-ydb960	[ern0]	  Test that $QUERY(gvn) returns correct results when global names are mapped at the subscript level
# ignore_restrict_on_write_auth-ydb1085		[ern0]	  Test that restrict.txt is completely ignored if it has write auth
# zextract_utf8_literal-ydb1093			[nars]	  Test that $ZEXTRACT does not behave like $EXTRACT in UTF-8 mode for literal parameters
# relinkctl_perm_umask-ydb1087			[nars]	  Test that relinkctl file is writable by any userid that can read the routine object directory
# lots_of_lvns_assert-ydb1088			[nars]	  Test that lots of lvns usage does not assert fail in lv_getslot.c
# jnlswitch_set_perf-ydb959			[nars]	  Test no dramatic loss of global SET performance during jnl file switch
# zgbldirundef-ydb999				[nars]	  Test ZGBLDIRUNDEF error is issued when ydb_gbldir env var is undefined or set to ""
# shebang-ydb1084				[nars]	  Test shebang support of yottadb
# fallintoflst-ydb1097				[nars]	  Test FALLINTOFLST error is issued even when falling through dotted DO lines
# mumps_machine_lis-assertfailure		[nars]	  Test that MUMPS -MACHINE -LIS does not assert fail if more than 128 errors (test of YDB@4d509b3e)
# bool_expr_equ-ydb1091				[nars]	  Test that x=y and x'=y in simple boolean expressions are fast
# bool_expr_contain-ydb1091			[nars]	  Test that x[y and x'[y in simple boolean expressions are fast
# bool_expr_follow-ydb1091			[nars]	  Test that x]y and x']y in simple boolean expressions are fast
# bool_expr_pattern-ydb1091			[nars]	  Test that x?y and x'?y in simple boolean expressions are fast
# bool_expr_sortsafter-ydb1091			[nars]	  Test that x]]y and x']]y in simple boolean expressions are fast
# bool_expr_gt-ydb1091				[nars]	  Test that x>y and x'>y in simple boolean expressions are fast
# bool_expr_lt-ydb1091				[nars]	  Test that x<y and x'<y in simple boolean expressions are fast
# bool_expr_andor-ydb1091			[nars]	  Test performance of =, < etc. in boolean expressions with AND or OR
# various_fuzz-ydb1044				[ern0]    Test various code issues identified by fuzz testing
# ydb_hostname-ydb747				[pooh]    Test for testing ydb_hostname variable
# untimed_nodelim_socread-ydb1100		[nars]	  Test untimed nodelimiter socket READs return sooner than r2.00
#----------------------------------------------------------------------------------------------------------------------------------

echo "r202 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"rlsiglongjmp-ydb1065"
setenv subtest_list_non_replic	"$subtest_list_non_replic mupip_verbose-ydb1060"
setenv subtest_list_non_replic	"$subtest_list_non_replic zshow_tt_host_conv-ydb1068"
setenv subtest_list_non_replic	"$subtest_list_non_replic empty_socket_assert-ydb1076"
setenv subtest_list_non_replic	"$subtest_list_non_replic xcretnull-ydb1007"
setenv subtest_list_non_replic	"$subtest_list_non_replic relinkctl_crash-ydb1083"
setenv subtest_list_non_replic	"$subtest_list_non_replic max_truncate_to_error-ydb1048"
setenv subtest_list_non_replic	"$subtest_list_non_replic bool_expr_equnul-ydb777"
setenv subtest_list_non_replic	"$subtest_list_non_replic bad_query_res_on_mapped_sub_lvl-ydb960"
setenv subtest_list_non_replic	"$subtest_list_non_replic ignore_restrict_on_write_auth-ydb1085"
setenv subtest_list_non_replic	"$subtest_list_non_replic zextract_utf8_literal-ydb1093"
setenv subtest_list_non_replic	"$subtest_list_non_replic relinkctl_perm_umask-ydb1087"
setenv subtest_list_non_replic	"$subtest_list_non_replic lots_of_lvns_assert-ydb1088"
setenv subtest_list_non_replic	"$subtest_list_non_replic jnlswitch_set_perf-ydb959"
setenv subtest_list_non_replic	"$subtest_list_non_replic zgbldirundef-ydb999"
setenv subtest_list_non_replic	"$subtest_list_non_replic shebang-ydb1084"
setenv subtest_list_non_replic	"$subtest_list_non_replic fallintoflst-ydb1097"
setenv subtest_list_non_replic	"$subtest_list_non_replic mumps_machine_lis-assertfailure"
setenv subtest_list_non_replic	"$subtest_list_non_replic bool_expr_equ-ydb1091"
setenv subtest_list_non_replic	"$subtest_list_non_replic bool_expr_contain-ydb1091"
setenv subtest_list_non_replic	"$subtest_list_non_replic bool_expr_follow-ydb1091"
setenv subtest_list_non_replic	"$subtest_list_non_replic bool_expr_pattern-ydb1091"
setenv subtest_list_non_replic	"$subtest_list_non_replic bool_expr_sortsafter-ydb1091"
setenv subtest_list_non_replic	"$subtest_list_non_replic bool_expr_gt-ydb1091"
setenv subtest_list_non_replic	"$subtest_list_non_replic bool_expr_lt-ydb1091"
setenv subtest_list_non_replic	"$subtest_list_non_replic bool_expr_andor-ydb1091"
setenv subtest_list_non_replic	"$subtest_list_non_replic various_fuzz-ydb1044"
setenv subtest_list_non_replic	"$subtest_list_non_replic ydb_hostname-ydb747"
setenv subtest_list_non_replic	"$subtest_list_non_replic untimed_nodelim_socread-ydb1100"
setenv subtest_list_non_replic	"$subtest_list_non_replic callout_io-ydb1056"
setenv subtest_list_replic	"loginterval-ydb1098"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	# Disable the below subtest because it is a white-box test.
	setenv subtest_exclude_list "$subtest_exclude_list rlsiglongjmp-ydb1065"
	# Disable the below subtest because it uses "gdb" to set breakpoints but does not work on some systems (not clear why).
	setenv subtest_exclude_list "$subtest_exclude_list relinkctl_crash-ydb1083"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r202 test DONE."
