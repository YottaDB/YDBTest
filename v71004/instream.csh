#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
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
# jnlext_maxvalue-gtm10687		[nars]	Test GDE and MUPIP report the maximum journal file size as the maximum journal extension
# ztrapexception_stpgcol-gtm10688	[nars]	Test SET $ZTRAP and EXCEPTION keep the right value if a garbage collection happens while they are validated
# dbperms_umask-gtm9272		[jon]	Test create database files with permissions from umask
# dollarstorage_rlimitdata-gtm9833	[jon]	Test $STORAGE reports the correct value when there is a restriction on the data segment limit (RLIMIT_DATA) of a process
# readsocket_minusone-gtm9855		[jon]	Test READ * from a socket returns -1 if the read fails
# zeditextcall_tpnotacid-gtm10099	[jon]	Check ZEDIT and external calls for TPNOTACID issues
# incrstat-gtm10123	[jon]	Test add $INCREMENT() statistic
#----------------------------------------------------------------------------------------------------------------------------------

echo "v71004 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_non_replic	"$subtest_list_non_replic jnlext_maxvalue-gtm10687"
setenv subtest_list_non_replic	"$subtest_list_non_replic ztrapexception_stpgcol-gtm10688"
setenv subtest_list_non_replic	"$subtest_list_non_replic dbperms_umask-gtm9272"
setenv subtest_list_non_replic	"$subtest_list_non_replic dollarstorage_rlimitdata-gtm9833"
setenv subtest_list_non_replic	"$subtest_list_non_replic readsocket_minusone-gtm9855"
setenv subtest_list_non_replic	"$subtest_list_non_replic zeditextcall_tpnotacid-gtm10099"
setenv subtest_list_non_replic	"$subtest_list_non_replic incrstat-gtm10123"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	# The below subtest uses a white-box test case, which only a debug build has
	setenv subtest_exclude_list "$subtest_exclude_list ztrapexception_stpgcol-gtm10688"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# defines "gtm_test_libyottadb_asan_enabled" env var
if ($gtm_test_libyottadb_asan_enabled) then
	# dollarstorage_rlimitdata-gtm9833 limits the data segment size (RLIMIT_DATA), which also limits private writable
	# mappings. The address sanitizer maps terabytes of shadow memory that way, so no process can start under the limit.
	setenv subtest_exclude_list "$subtest_exclude_list dollarstorage_rlimitdata-gtm9833"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v71004 test DONE."
