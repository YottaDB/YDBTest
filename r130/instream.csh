#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2025 YottaDB LLC and/or its subsidiaries.	#
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
# ydb485 [gm]        Tests $ZCONVERT with 3 parameters to ensure correct decimal to hexadecimal and vice versa conversion
# ydb518 [bdw]       Tests call ins and external calls using ydb_int64_t and ydb_uint64_t
# ydb520 [bdw]       Tests to ensure that $ETRAP and $ZTRAP are being set correctly
# ydb503 [bdw]       Tests if DRD is incremented/not incremented correctly in both MM and BG access modes.
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
# ydb567 [bdw]       Test that a MUPIP INTRPT in the middle of a hang in a for loop does not cause an assert failure
# ydb576 [nars]      Test that $PIECE in a database trigger returns correct results when invoked from SimpleAPI (e.g. ydb_set_s())
# ydb578 [nars]      Test that LVUNDEF error displays string subscripts with surrounding double quotes
# ydb492 [nars]      Test $TRANSLATE with multi-byte string literals in UTF-8 mode does not SIG-11 if executed from shared library
# ydb566 [bdw]       Test that Call-In tables and External Call definitions support comments and blank lines
# ydb569 [gm]        Ensures new -ignorechset option for mupip load is able to ignore extract file CHSET
# ydb589 [nars]      Test that buffered IO writes inside external call are flushed when YottaDB process output is piped
# ydb592 [nars]      Test that ps identifies JOB'd process with the same name as the parent
# ydb594 [nars]      Test SimpleAPI returns correct results if lvn was set using ydb_incr_s()
# ydb494 [gm]        Ensures that mupip extract handles labels with spaces correctly
# ydb595 [mw]        Tests $ydb_dist/yottadb -version to verify that it includes $ZYRELEASE, $ZVERSION, and $ZRELDATE
# ydb525 [bdw]       That to verify that $io is set correctly after a SILENT^%RSEL
# ydb607 [bdw]       Test that flush_trigger_top is auto-upgraded correctly when the old version is R1.22 or R1.24
# ydb568 [nars]      Test that Interrupted MUPIP EXTRACT STDOUT to a pipe does not leave terminal in unfriendly state
# ydb587 [sp]        Ensures that dollar_test is set based on environment variable ydb_dollartest
# ydb560 [nars]      Test that MUPIP STOP (SIG-15) and SIG-4 terminate an M program running an indefinite FOR loop
# ydb388 [nars]      Test 8-byte csd->flush_time is correctly auto upgraded and endian converted
#----------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r130 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ydb470 ydb482 ydb174 ydb390 ydb476 ydb511 ydb513 ydb485 ydb518 ydb520 ydb503 ydb515 ydb519 ydb545"
setenv subtest_list_non_replic "${subtest_list_non_replic} ydb553 ydb547 ydb493 ydb549 ydb562 ydb554 ydb484 ydb534 ydb567 ydb576"
setenv subtest_list_non_replic "${subtest_list_non_replic} ydb578 ydb492 ydb566 ydb569 ydb589 ydb592 ydb594 ydb494 ydb595 ydb525"
setenv subtest_list_non_replic "${subtest_list_non_replic} ydb607 ydb568 ydb587 ydb560 ydb388"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

if ($gtm_platform_size != 64) then
	## Disable ydb518 on non-64-bit machines
	setenv subtest_exclude_list "$subtest_exclude_list ydb518"
endif

if (("armv6l" == `uname -m`) || ("aarch64" == `uname -m`)) then
	# On ARMV6L systems with Debian 11, we have seen the below subtest crash the system in mysterious ways.
	# Running this huge M program (that has 1 million lines) seems to take up a lot more memory than available
	# in the system and it starts using swap. But not sure what happens at that point, the system becomes
	# unreachable even though gigabytes of swap space has been configured. So disable this on ARMV6L.
	#
	# On AARCH64 systems, we have seen the ydb547 subtest fail with a SIG-11 occasionally.
	# Both failures so far have been when huge pages were enabled. And we saw the following messages in the syslog
	#	"kernel: yottadb: page allocation failure"
	# Therefore we want to disable this subtest when huge pages is enabled.
	# But even when huge pages is disabled, this test takes hours to run and it is not considered worth the
	# effort to test this heavyweight test on AARCH64. Hence we disable this irrespective of huge pages setting.
	setenv subtest_exclude_list "$subtest_exclude_list ydb547"
endif

# ydb607 requires specific older versions for the test. Skip if not present. -ck
# flag is to prevent the script from killing the test using an exit().
set rand_ver=`$gtm_tst/com/random_ver.csh -gte V63003 -lt V63007 -ck true`
if ( "$rand_ver" == "RANDOMVER-E-CANNOTRUN") then
	setenv subtest_exclude_list "$subtest_exclude_list ydb607"
endif

if ("pro" == "$tst_image") then
	source $gtm_tst/com/is_libyottadb_asan_enabled.csh
	if ($gtm_test_libyottadb_asan_enabled) then
		# We see cores when ASAN is used with tests that send signals (ydb534 sends SIGABRT etc.)
		# This happens whether YottaDB is compiled with gcc or clang.
		# And the stack traces are inside ASAN code where a SIG-11 occurs as well.
		# There is an indication of stack smash error too in some cases.
		# Not yet sure if it is an ASAN issue or a YottaDB issue inside the signal handler.
		# Exclude this subtest until we can find time to investigate this further.
		# The same test runs fine without ASAN and so is enabled in that case.
		setenv subtest_exclude_list "$subtest_exclude_list ydb534"
	endif
else
	# ydb534 subtest generates a SIGABRT signal which causes an assert in `generic_signal_handler.c` assert(SIGABRT != sig)`
	# to fail hence this subtest needs to be skipped in dbg (i.e. run it only in pro).
	setenv subtest_exclude_list "$subtest_exclude_list ydb534"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r130 test DONE."
