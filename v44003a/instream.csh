#!/usr/local/bin/tcsh -f
#
# ------------------------------------------------------------------------------
# for bugs fixed in V44003A
# ------------------------------------------------------------------------------
# D9D12002403 [Malli] Setting ZBREAK on line accessing more than 8 locals fails
# D9D12002404 [Malli] %GTM-F-GTMCHECK, Internal GT.M error
# D9D10002377 [Narayanan] The CLI parameter values are not reliable when read from CLI prompts
# C9D12002473 [Layek]     JNLBADRECFMT error from ideminter_rolrec test (this subtest uses replication server but $test_replic == 0)
# D9D12002402 [Narayanan] TID in the journal extract seems to be from innermost TSTART not outermost
# C9D12002478 [Malli]    marvin dbg cores with v44003 (find_line_addr has SEGV)
# D9D12002398 [Layek]	D9D12-002398 BEGSEQGTENDSEQ error as part of crash recovery testing at KTB
# ------------------------------------------------------------------------------
#
# The first subtest to be included in subtest_list_replic below will necessitate 
#	a) a change to suite.txt to enable the test to be run with replication 
#	b) a change to outref.txt to handle replication as well as non-replication test runs using ##TEST_AWK macros
#
echo "V44003a test starts..."
setenv subtest_list_common ""
setenv subtest_list_replic "D9D12002398"
setenv subtest_list_non_replic "D9D12002403 D9D12002404 D9D10002377 C9D12002473 D9D12002402 C9D12002478"
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
# filter out subtests that cannot pass with MM
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "C9D12002473"
endif
$gtm_tst/com/submit_subtest.csh
echo "V44003a test DONE."
