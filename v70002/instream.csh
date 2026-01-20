#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.	#
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
# backup_order-gtmf135842        [pooh]    MUPIP BACKUP supports user specified order
# load_binary-gtmde201381        [pooh]    MUPIP LOAD -FORMAT=BINARY uses only data length in checking for maximum length
# zchar_length-gtmde201378       [pooh]    Prevent $[Z]CHAR() representions from generating results longer than the maximum string length
# backup_env-gtmde201305         [pooh]    MUPIP BACKUP works if environment variables used in segment to database file mapping are not defined
# sock_devparam-gtmde201380      [pooh]    SOCKET device commands defend against large deviceparameter arguments
# sighup_error-gtmde222430       [pooh]    Prevent fatal errors from disconnect/hangup
# block_split-gtmf135414         [pooh]    Test Proactive Database Block Splitting
# sigintdiv-gtmde201386          [ern0]    Verify that unusual combination of calculation does not produce SIGINTDIV/asserts
# ctrap_acsii-gtmde201390        [pooh]    CTRAP only recognizes characters with ASCII codes 0-31 inclusive
# view_arg_too_long-gtmde201386  [ern0]    Verify that VIEW "NOISOLATION" does not produce SIGSEGV on malformed or too long args
# fnum_just-gtmde201386          [ern0]    Verify that strange parameters in $FNUMBER() and $JUSTIFY() functions do not cause SIGSEGV
# zsyslog_fao-gtmde201386        [ern0]    Verify that $ZSYSLOG() ignores Format Ascii Output (FAO) directives, no SEGSIGV
# ygblstat-gtmf132372            [ern0]    Check if YGBLSTAT reports WRL, PRG, WFL, and WHE fields in statistics
# indirection-gtmde201393        [berwyn]  @x@y indirection correctly handles comments in x
# zjobexam_2ndargs-gtmf135292    [pooh]    Optional second argument to $ZJOBEXAM() to control its output
# malloc_limit-gtmf135393        [berwyn]  test trappable high-memory usage warning
# stp_gcol_src_assert-gtmf135393 [berwyn]  Test assert failure in sr_port/stp_gcol_src.h line 932 in GT.M V7.0-002
# rctl_integ-gtmf135435          [pooh]    Routine shared object integrity check & repair
# strlit_numoflow-gtmde201388	 [pooh]    Better handling of literal arguments that cause numeric overflow
# patternMatchGuard-gtmde201389	 [ern0]    Verify that pattern match better guards against deep recursion
#----------------------------------------------------------------------------------------------------------------------------------

echo "v70002 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_non_replic	"$subtest_list_non_replic backup_order-gtmf135842"
setenv subtest_list_non_replic	"$subtest_list_non_replic load_binary-gtmde201381"
setenv subtest_list_non_replic	"$subtest_list_non_replic zchar_length-gtmde201378"
setenv subtest_list_non_replic	"$subtest_list_non_replic backup_env-gtmde201305"
setenv subtest_list_non_replic	"$subtest_list_non_replic sock_devparam-gtmde201380"
setenv subtest_list_non_replic	"$subtest_list_non_replic sighup_error-gtmde222430"
setenv subtest_list_non_replic	"$subtest_list_non_replic block_split-gtmf135414"
setenv subtest_list_non_replic	"$subtest_list_non_replic sigintdiv-gtmde201386"
setenv subtest_list_non_replic	"$subtest_list_non_replic ctrap_acsii-gtmde201390"
setenv subtest_list_non_replic	"$subtest_list_non_replic view_arg_too_long-gtmde201386"
setenv subtest_list_non_replic	"$subtest_list_non_replic fnum_just-gtmde201386"
setenv subtest_list_non_replic	"$subtest_list_non_replic zsyslog_fao-gtmde201386"
setenv subtest_list_non_replic	"$subtest_list_non_replic ygblstat-gtmf132372"
setenv subtest_list_non_replic	"$subtest_list_non_replic indirection-gtmde201393"
setenv subtest_list_non_replic	"$subtest_list_non_replic zjobexam_2ndargs-gtmf135292"
setenv subtest_list_non_replic	"$subtest_list_non_replic malloc_limit-gtmf135393"
setenv subtest_list_non_replic	"$subtest_list_non_replic stp_gcol_src_assert-gtmf135393"
setenv subtest_list_non_replic	"$subtest_list_non_replic rctl_integ-gtmf135435"
setenv subtest_list_non_replic	"$subtest_list_non_replic strlit_numoflow-gtmde201388"
setenv subtest_list_non_replic	"$subtest_list_non_replic patternMatchGuard-gtmde201389"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""
# This test occasionally but frequently fails due to variations in the numbers of blocks reported from MUPIP INTEG
# for the PROBLKSPLIT feature. However, this feature was disabled by default as of GT.M V7.1-001. So this test is disabled.
# For more details, see: https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2548#note_3021292834
setenv subtest_exclude_list "$subtest_exclude_list block_split-gtmf135414"

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	# This is a white-box test case and is why needs to be disabled for PRO builds.
	setenv subtest_exclude_list "$subtest_exclude_list rctl_integ-gtmf135435"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

source $gtm_tst/com/is_libyottadb_asan_enabled.csh      # defines "gtm_test_libyottadb_asan_enabled" env var
if ($gtm_test_libyottadb_asan_enabled) then
	# libyottadb.so was built with address sanitizer (which also includes the leak sanitizer)
	# That creates shadow memory to keep track of memory leaks and allocates that at a very big address.
	# That fails with tests that limit virtual memory. Therefore disable such subtests when ASAN is enabled.
	setenv subtest_exclude_list "$subtest_exclude_list malloc_limit-gtmf135393"
	setenv subtest_exclude_list "$subtest_exclude_list stp_gcol_src_assert-gtmf135393"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v70002 test DONE."
