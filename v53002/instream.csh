#!/usr/local/bin/tcsh -f
#
# -------------------------------------------------------------------------------------
# for stuff fixed in V53001A, V53002
# -------------------------------------------------------------------------------------
# C9E04002596 [Narayanan] Test multiple gld mapping regions to the same physical file
# C9I02002956 [Narayanan] MUPIP INTEG does not report DBINVGBL integrity error
# C9D12002471 [se] Test outofmemory condition for (new) correct handling.
# C9I02002963 [Narayanan] SET $ZGBLDIR followed by TSTART fails with SIG-11
# D9I03002674 [Kishore,SE] Name indirection may fail with NOUNDEF
# C9E08002617 [Narayanan] GTMASSERT in get_symb_line.c in some $ETRAP testcases
# D9I03002676 [Narayanan] Nested STACKCRIT errors & Incorrect $ZSTATUS reports
# C9C11002181 [Narayanan] Errors should never leave GT.M in direct mode unless $ZT contains BREAK
# C9F06002736 [Narayanan] DSE MAPS -RESTORE has issues if total_blks is multiple of 512
# D9I05002682 [Narayanan] Update process should disallow updates to non-replicated databases
# C9I07003006 [Kishore,NR] Assert fail in op_unwind.c line 48 if runtime error in indirection & NEW in $ET
# C9I06003000 [Kishore,NR] Source server runs into an infinite loop while reading from journal files
# D9I07002688 [Roger] test for warning only for non-graphic characters in a string literal at compile-time
# D9I07002689 [Roger] test of $ZQUIT (anyway) compilation
# D9I07002692 [Roger] test of zprint with an object-source mismatch
# D9I07002690 [kishore] GTMASSERT in JNL_FILE_EXTEND.C;1 line 101 using V44004 at CSOB
# C9I07003009 [roger] test that a zhelp error leaves $ecode=""
# -------------------------------------------------------------------------------------
#
echo "V53002 test starts..."
setenv subtest_list_common ""
setenv subtest_list_replic "D9I05002682 C9I06003000"
setenv subtest_list_non_replic "C9E04002596 C9I02002956 C9D12002471 C9I02002963 D9I03002674 C9E08002617 D9I03002676 C9C11002181"
setenv subtest_list_non_replic "$subtest_list_non_replic C9F06002736 C9I07003006 D9I07002688 D9I07002689 D9I07002692 D9I07002690 C9I07003009"
setenv subtest_list_non_replic_FE ""
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
	if ("L" != $LFE) then
		setenv subtest_list "$subtest_list $subtest_list_non_replic_FE"
	endif
endif
setenv subtest_exclude_list ""
# filter out a specific subtest for some servers:
if (("hp-ux" == "$gtm_test_osname") || ("aix" == "$gtm_test_osname") || ("os390" == "$gtm_test_osname")) then
        # In AIX, the subtest fails with "GTM-F-KRNLKILL, Process was terminated by SIGDANGER signal"
	# HP-UX IA64 becomes non-responsive for long periods of time when the subtest runs
        # So temporarily disable the subtest in AIX and HP-UX until
        # a) A solution is found to limit vmemory (like the limit command) or
        # b) All such resource intensive subtests are moved to manually_start test.
	setenv subtest_exclude_list "$subtest_exclude_list C9D12002471"
endif
# filter out subtests that cannot pass with MM
# C9I06003000	Has to run with BEFORE image journaling
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "$subtest_exclude_list C9I06003000"
endif

$gtm_tst/com/submit_subtest.csh
echo "V53002 test DONE."
