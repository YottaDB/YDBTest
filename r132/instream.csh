#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020-2023 YottaDB LLC and/or its subsidiaries.	#
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
# ydb627 [nars]        Test that $FNUMBER(num,"",N)=num when N is non-zero returns 0
# ydb551 [sp]          Test to check $ZSYSLOG() doesn't break formatting when certain strings passed
# ydb632 [estess]      Test if resuming after a signal in a TP callback routine can cause a hang.
# ydb581 [sp]          Test to see $ZPARSE() fetches symbolically linked files
# ydb657 [nars]        Test that replication connection happens using TLS 1.3 if OpenSSL >= 1.1.1 and TLS 1.2 otherwise
# ydb630 [sp]          Test to see that $ZSYSLOG() uses consistent process names for ydb process
# ydb441 [bdw]         Test that Auto-ZLINK works properly when zlinking a new version of an M file after changing $ZROUTINES
# ydb652 [bdw]         Test that %HO correctly converts input between DE0B6B3A7640001 and FFFFFFFFFFFFFFF to octal
# ydb635 [sp]          Test that checks MUPIP INTEG (no options) honors Ctrl-C and exits cleanly
# ydb664 [nars]        Test that VIEW "ZTRIGGER_OUTPUT":0 disables $ZTRIGGER related output
# ydb663 [bdw]         Test that loading a binary extract back into the same database doesn't produce a DBDUPNULCOL error
# ydb558 [sam]         Test that zshow "*":lvn does not include zshow "I" output into zshow "V" values in lvn
# ydb612 [sam]         Test that suspending (CTRL-Z) YottaDB direct mode and then foregrounding it doesn't cause an assert
# ydb591 [sam]         Remove ifdef TCP_NODELAY from YottaDB codebase, test ZDELAY and ZNODELAY still work
# ydb391 [sam]         Implement $ZYSUFFIX: Provide name equivalent to 128-bit hash
# ydb678 [nars]        Test of new ISV $ZYINTRSIG
# ydb671 [sam]         Implement -stdin/-stdout for mupip trigger
# ydb676 [bdw,nars]    Test that mupip journal -rollback -fetchresync resets the connection if it receives bad input
# ydb682 [bdw]         Test that %HO converts hexadecimal numbers to the same octal number with or without "0x" prefix
# ydb673 [nars,estess] Test that LOCK with 0 timeout successfully obtains an unowned lock if 32+ M lock hash values hash to same
#                      bucket (neighborhood full issue).
# ydb697 [bdw]         Test that %CONVNEG^%CONVBASEUTIL produces correct two's complement results for octal numbers
# ydb700 [nars]        Test that Multi-line -xecute in $ztrigger() accepts trailing ">>" and -piece/-delim etc. after -xecute
# ydb692 [nars]        Test that modulo operator returns purely numeric result even if dividend is a mix of number and string
# ydb505 [nars]        Test that OBJECT qualifier without a value does not assert fail or issue unfriendly NOTMNAME error
# ydb717 [nars]        Test that MUPIP SIZE -HEURISTIC="SCAN,LEVEL=1" -SUBSCRIPT gives accurate results (not a MUSIZEFAIL error)
# ydb712 [estess]      Test that a $ZINTERRUPT that fires while in direct mode and the code fragment gets an error works correctly
# ydb724 [estess]      Test various facets of $ZATRANSFORM() found to be incorrect without ydb724.
# ydb721 [nars]        Test that LKE SHOW does not insert a line feed after a lock reference longer than 24 characters
# ydb731 [nars]        Test $VIEW("WORDEXP")
# ydb737 [sam]         Test Call-in APIs don't know how to handle $QUIT
# ydb739 [bdw]         Test MUPIP INTEG -SUBSCRIPT with null subscripts and no end key.
# ydb688 [sam,nars]    Test ZWRITE with pattern match no longer fails with LVUNDEF if DB has null subscripts enabled
# ydb629 [nars]        Test Unary + works on $ZYSQLNULL returned by $ORDER(lvn)
# ydb741 [nars]        Test DSE REMOVE -RECORD does not SIG-11 in case of DBCOMPTOOLRG integrity error
# ydb704 [bdw]         Test that invoking YottaDB via valgrind works
# ydb749 [nars]        Test that huge transactions work fine or issue TRANSREPLJNL1GB error as appropriate
# ydb715 [nars]        Test that MUPIP JOURNAL RECOVER/ROLLBACK work fine even if an AutoDB database file does not exist
# ydb709 [nars]        Test that $VIEW("GVFILE") works on db file name with env vars and for GT.CM regions
#----------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r132 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "ydb749"
setenv subtest_list_non_replic "ydb627 ydb551 ydb632 ydb581 ydb630 ydb441 ydb652 ydb635 ydb664 ydb663 ydb558 ydb612 ydb591 ydb391"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb678 ydb671 ydb682 ydb673 ydb697 ydb700 ydb692 ydb505 ydb717 ydb712"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb724 ydb721 ydb731 ydb737 ydb739 ydb688 ydb629"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb741 ydb704 ydb715 ydb709"
setenv subtest_list_replic     "ydb657 ydb676"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""
# filter out test that needs to run pro-only
if ("pro" != "$tst_image") then
       setenv subtest_exclude_list "$subtest_exclude_list ydb632" # ydb632 generates core and stop in dbg, continues in pro
endif
if ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) then
	# filter out below subtest on 32-bit ARM since it requires valgrind which is not available on 32-bit ARM
	setenv subtest_exclude_list "$subtest_exclude_list ydb704"
endif

source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# defines "gtm_test_libyottadb_asan_enabled" env var
if ($gtm_test_libyottadb_asan_enabled) then
	# libyottadb.so was built with address sanitizer (which also includes the leak sanitizer)
	# That does similar functionality as valgrind and therefore cannot coexist.
	# Therefore filter out below subtest that uses valgrind.
	setenv subtest_exclude_list "$subtest_exclude_list ydb704"
endif

# Temporarily disable ydb704 subtest on builds built with CLANG 14 or CLANG 15 as it fails with error messages
# like the below due to valgrind not yet supporting CLANG 14 or 15.
#	### unhandled dwarf2 abbrev form code 0x25
if (("14" == "$clangmajorver") || ("15" == "$clangmajorver")) then
	setenv subtest_exclude_list "$subtest_exclude_list ydb704"
endif

# Disable ydb704 subtest on Arch Linux because valgrind currently doesn't
# work on the in-house Arch machine and setting DEBUGINFOD_URLS didn't
# fix the failures long-term.
if ("arch" == $gtm_test_linux_distrib) then
	setenv subtest_exclude_list "$subtest_exclude_list ydb704"
endif

if ($gtm_test_libyottadb_asan_enabled && ("clang" == $gtm_test_asan_compiler)) then
	# libyottadb.so was built with ASAN and CLANG.
	#
	# With ASAN and CLANG 11 or CLANG 12 on Ubuntu, we have seen the ydb632 subtest fail with the following diff
	#
	# --- ydb632/ydb632.diff ---
	# 12a13,15
	# > ==40940==WARNING: ASan is ignoring requested __asan_handle_no_return: stack top: 0x7ffedd7c3000; bottom 0x7feae521a000; size: 0x0013f85a9000 (85771063296)
	# > False positive error reports may follow
	# > For details see https://github.com/google/sanitizers/issues/189
	#
	# With ASAN and CLANG 13 on Ubuntu, we did not see such a failure.
	# But With ASAN and CLANG 13 on SUSE, we see failures like the following.
	#
	#   ASAN:DEADLYSIGNAL
	#   =================================================================
	#   ==44982==ERROR: AddressSanitizer: SEGV on unknown address 0x000000000000 (pc 0x000000400c2a bp 0x7ffcf041d590 sp 0x7ffcf041d530 T0)
	#   ==44982==The signal is caused by a READ memory access.
	#   ==44982==Hint: address points to the zero page.
	#
	# With ASAN and GCC though we have not seen any of the above issues.
	#
	# Given that this subtest does intentionally trigger a SIG-11, I think it is not worth it trying it to
	# make it work with CLANG and ASAN. So we disable it in that case.
	setenv subtest_exclude_list "$subtest_exclude_list ydb632"
endif

# Disable ydb749 subtest as it is a heavyweight test and will take a lot of time on non-x86_64 (i.e. ARM).
# The code is portable and so it is enough to test it only on x86_64.
# Also disable this test on Debug builds as it takes a long time due to "upd_num" increasing order check in debug code in tp_tend.c
# that can take really long time for this particular subtest due to it doing millions of sets.
if (("HOST_LINUX_X86_64" != $gtm_test_os_machtype) || ("pro" != "$tst_image")) then
	setenv subtest_exclude_list "$subtest_exclude_list ydb749"
else if ($?ydb_test_exclude_ydb749) then
	if ($ydb_test_exclude_ydb749) then
		setenv subtest_exclude_list "$subtest_exclude_list ydb749"
	endif
endif

# Readline version
# This bug shows up in Readline v7, and has since been fixed
# https://lists.gnu.org/archive/html/bug-readline/2017-03/msg00010.html
# Valgrind shows the bug in test ydb704
# If $gtm_tst_readline_version is less than 8, then exclude this test
if ($?gtm_tst_readline_version) then
	if ($gtm_tst_readline_version < 8) then
		setenv subtest_exclude_list "$subtest_exclude_list ydb704"
	endif
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r132 test DONE."
