#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
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
# relinkctl_crash-ydb1083			[nars]    Test that relinkctl file latch is salvaged in 1 second (not 1 minute) after crash
# max_truncate_to_error-ydb1048			[david]	  Test that command utilities with input that is too long, return errors, rather than truncate
# bool_expr_equnul-ydb777       		[nars]    Test that s="" and s'="" in simple boolean expressions are fast
# bad_query_res_on_mapped_sub_lvl-ydb960	[ern0]    Test that $QUERY(gvn) returns correct results when global names are mapped at the subscript level
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
setenv subtest_list_replic	""

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
