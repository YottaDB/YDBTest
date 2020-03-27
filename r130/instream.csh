#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#----------------------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# ydb470 [bdw]       Tests ydb_init() to make sure that $gtm_dist is set correctly when it is initially null or different from $ydb_dist
# ydb482 [bdw]       Tests $ZJOBEXAM with 2 parameters to ensure the second parameter is working correctly
# ydb174 [bdw]       Ensures that naked references follow the max subscript limit
# ydb390 [bdw]       Tests $ZYHASH and ydb_mmrhash_128 to ensure that their outputs are equivalent
# ydb476 [gm]        Tests $ZSigproc for its correctness with named string signal value as second argument
# ydb511 [bdw]       Tests $translate with undefined variables for the 2nd and 3rd arguments.
# ydb513 [nars]      Test that $VIEW("REGION","^*") returns the name of the region mapped to by the `*` namespace
# ydb485 [gm]	     Tests $ZCONVERT with 3 parameters to ensure correct decimal to hexadecimal and vice versa conversion
# ydb518 [bdw]       Tests call ins and external calls using ydb_int64_t and ydb_uint64_t
# ydb520 [bdw]       Tests to ensure that $ETRAP and $ZTRAP are being set correctly
# ydb503 [bdw]	     Tests if DRD is incremented/not incremented correctly in both MM and BG access modes.
# ydb515 [see]       Test that ydb_zstatus() does not write to null buffers
# ydb519 [bdw]       Tests opening sockets to ensure that user-specified timeouts are followed
# ydb545 [see]       Test that a LOCK cmd subsequent to a LOCk cmd that failed with an error does not return BADLOCKNEST
# ydb553 [nars]      Test boolean expression compiles involving NOT operator (') and side effects (used to spin loop if ydb_boolean=1)
# ydb547 [nars]      Test that no SYSTEM-E-UNKNOWN/SIG-11 occurs on ARMV7L when invoked function is hundred thousands of M lines apart
# ydb493 [gm]        Ensures default label seen with extract and load has yottadb, path, command & parameters
# ydb549 [bdw,nars]  Ensure that environment variables are expanded correctly when initializing $zroutines
# ydb562 [nars]      Test that SET $ZROUTINES="..." and SET $ZROUTINES="...." issue ZROSYNTAX error
# ydb554 [nars]      Test boolean expression compiles involving side effects used in a context that requires an integer (used to GTMASSERT if ydb_boolean=1)
# ydb484 [nars]      Test of $ZYSQLNULL and $ZYISSQLNULL()
# ydb534 [nars]      Test that SIGABRT generates core (default action for SIGABRT) in SimpleThreadAPI mode without any hangs
#----------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r130 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ydb470 ydb482 ydb174 ydb390 ydb476 ydb511 ydb513 ydb485 ydb518 ydb520 ydb503 ydb515 ydb519 ydb545"
setenv subtest_list_non_replic "${subtest_list_non_replic} ydb553 ydb547 ydb493 ydb549 ydb562 ydb554 ydb484 ydb534"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list "
else
	# ydb534 subtest generates a SIGABRT signal which causes an assert in `generic_signal_handler.c` assert(SIGABRT != sig)`
	# to fail hence this subtest needs to be skipped in dbg (i.e. run it only in pro).
	setenv subtest_exclude_list "$subtest_exclude_list ydb534"
endif
if ($gtm_platform_size != 64) then
	## Disable ydb518 on non-64-bit machines
	setenv subtest_exclude_list "$subtest_exclude_list ydb518"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r130 test DONE."
