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
# dmode_intrpt_stackleak-gtm9815	[nars]	Test SIGUSR1 and SIGINT at the Direct Mode prompt do not leak M stack space
# dollartext_dbrolledback-gtm10150	[nars]	Test $TEXT() of a trigger issues DBROLLEDBACK after an online rollback
# epochtaper_loneupdater-gtm10623	[nars]	Test epoch tapering is inhibited if only one process does updates
# srcsrv_jnlfilemem-gtm9141		[nars]	Test the Source Server returns the memory used for older journal files to the operating system
# jnlext_maxvalue-gtm10687		[nars]	Test GDE and MUPIP report the maximum journal file size as the maximum journal extension
# ztrapexception_stpgcol-gtm10688	[nars]	Test SET $ZTRAP and EXCEPTION keep the right value if a garbage collection happens while they are validated
# dbperms_umask-gtm9272		[jon]	Test create database files with permissions from umask
# dollarstorage_rlimitdata-gtm9833	[jon]	Test $STORAGE reports the correct value when there is a restriction on the data segment limit (RLIMIT_DATA) of a process
# readsocket_minusone-gtm9855		[jon]	Test READ * from a socket returns -1 if the read fails
# zeditextcall_tpnotacid-gtm10099	[jon]	Check ZEDIT and external calls for TPNOTACID issues
# incrstat-gtm10123	[jon]	Test add $INCREMENT() statistic
# dollarref_zwrite-gtm10679	[jon]	Test maintain $REFERENCE to the last node it successfully processed for ZWRITE of a gvn
# zmaxtptime_mseclim-gtm10603	[jon]	Test provide millisecond accuracy and 60 second limit for $ZMAXTPTIME
# tpnotacid_limitretries-gtm10098	[jon]	Test limit TPNOTACID retries
# sleepstats_nonzero-gtm10554		[nars]	Test the JNS, JCS, WPCS and WFCS sleep time statistics increase when a process waits for a write by another process
#----------------------------------------------------------------------------------------------------------------------------------

echo "v71004 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_non_replic	"$subtest_list_non_replic dmode_intrpt_stackleak-gtm9815"
setenv subtest_list_non_replic	"$subtest_list_non_replic epochtaper_loneupdater-gtm10623"
setenv subtest_list_non_replic	"$subtest_list_non_replic jnlext_maxvalue-gtm10687"
setenv subtest_list_non_replic	"$subtest_list_non_replic ztrapexception_stpgcol-gtm10688"
setenv subtest_list_non_replic	"$subtest_list_non_replic dbperms_umask-gtm9272"
setenv subtest_list_non_replic	"$subtest_list_non_replic dollarstorage_rlimitdata-gtm9833"
setenv subtest_list_non_replic	"$subtest_list_non_replic readsocket_minusone-gtm9855"
setenv subtest_list_non_replic	"$subtest_list_non_replic zeditextcall_tpnotacid-gtm10099"
setenv subtest_list_non_replic	"$subtest_list_non_replic incrstat-gtm10123"
setenv subtest_list_non_replic	"$subtest_list_non_replic dollarref_zwrite-gtm10679"
setenv subtest_list_non_replic	"$subtest_list_non_replic zmaxtptime_mseclim-gtm10603"
setenv subtest_list_non_replic	"$subtest_list_non_replic tpnotacid_limitretries-gtm10098"
setenv subtest_list_non_replic	"$subtest_list_non_replic sleepstats_nonzero-gtm10554"
setenv subtest_list_replic	""
setenv subtest_list_replic	"$subtest_list_replic dollartext_dbrolledback-gtm10150"
setenv subtest_list_replic	"$subtest_list_replic srcsrv_jnlfilemem-gtm9141"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	# The below subtests use white-box test cases, which only a debug build has
	setenv subtest_exclude_list "$subtest_exclude_list ztrapexception_stpgcol-gtm10688"
	setenv subtest_exclude_list "$subtest_exclude_list sleepstats_nonzero-gtm10554"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# defines "gtm_test_libyottadb_asan_enabled" env var
if ($gtm_test_libyottadb_asan_enabled) then
	# dollarstorage_rlimitdata-gtm9833 limits the data segment size (RLIMIT_DATA), which also limits private writable
	# mappings. The address sanitizer maps terabytes of shadow memory that way, so no process can start under the limit.
	setenv subtest_exclude_list "$subtest_exclude_list dollarstorage_rlimitdata-gtm9833"
	# The below subtest checks how much memory a process returns to the operating system. An ASAN build keeps
	# freed memory in quarantine for some time, which changes those numbers.
	setenv subtest_exclude_list "$subtest_exclude_list srcsrv_jnlfilemem-gtm9141"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v71004 test DONE."
