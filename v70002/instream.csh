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
# backup_order-gtmf135842	[pooh]		MUPIP BACKUP supports user specified order
# load_binary-gtmde201381	[pooh]		MUPIP LOAD -FORMAT=BINARY uses only data length in checking for maximum length
# zchar_length-gtmde201378	[pooh]		Prevent $[Z]CHAR() representions from generating results longer than the maximum string length
# backup_env-gtmde201305	[pooh]		MUPIP BACKUP works if environment variables used in segment to database file mapping are not defined
# sock_devparam-gtmde201380	[pooh]		SOCKET device commands defend against large deviceparameter arguments
# sighup_error-gtmde222430	[pooh]		Prevent fatal errors from disconnect/hangup
# block_split-gtmf135414	[pooh]		Test Proactive Database Block Splitting
# sigintdiv-gtmde201386 	[ern0] 		Verify that unusual combination of calculation does not produce SIGINTDIV/asserts
# ctrap_acsii-gtmde201390	[pooh]		CTRAP only recognizes characters with ASCII codes 0-31 inclusive
# view_arg_too_long-gtmde201386	[ern0]	Verify that VIEW "NOISOLATION" does not produce SIGSEGV on malformed or too long args
# fnum_just-gtmde201386 	[ern0] 		Verify that strange parameters in $FNUMBER() and $JUSTIFY() functions do not cause SIGSEGV
# zsyslog_fao-gtmde201386	[ern0] 		Verify that $ZSYSLOG() ignores Format Ascii Output (FAO) directives, no SEGSIGV
# ygblstat-gtmf132372		[ern0] 		Check if YGBLSTAT reports WRL, PRG, WFL, and WHE fields in statistics
# indirection-gtmde201393	[berwyn]    @x@y indirection correctly handles comments in x
#----------------------------------------------------------------------------------------------------------------------------------

echo "v70002 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"backup_order-gtmf135842 load_binary-gtmde201381 zchar_length-gtmde201378 backup_env-gtmde201305"
setenv subtest_list_non_replic	"$subtest_list_non_replic sock_devparam-gtmde201380 sighup_error-gtmde222430"
setenv subtest_list_non_replic	"$subtest_list_non_replic block_split-gtmf135414 sigintdiv-gtmde201386 ctrap_acsii-gtmde201390"
setenv subtest_list_non_replic	"$subtest_list_non_replic view_arg_too_long-gtmde201386 fnum_just-gtmde201386 zsyslog_fao-gtmde201386"
setenv subtest_list_non_replic	"$subtest_list_non_replic ygblstat-gtmf132372 indirection-gtmde201393"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v70002 test DONE."
