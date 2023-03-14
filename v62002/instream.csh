#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# gtm8197          [partridger] Test to verify that an over-length trigger specification produces a TRIGNAMENF error
# gtm3912          [partridger] Test that narrow terminal widths don't cause problems for ZSHOW "D" (GTM-3912) or ZWRITE (GTM-5756)
# gtm8187          [nars]       Test to verify that mupip reorg -truncate does optimal truncation
# gtm8167          [base]       Verify buffer overrun does not occur when job command arguments are greater than 1024 bytes long
# gtm4911          [partridger] Test that timed read longer than the heartbeat timer (8 seconds) works appropriately
# gtm8241          [nars]       Test to ensure lock wait does not hog crit as # of waiting processes runs to thousands
# gtm8228          [nars]       Releasing M-lock should not require crit at process exit
# gtm8214          [nars]       SIG-11 and/or garbage printed in $ztrigger update operations
# gtm8269          [nars]       KILL of global with NOISOLATION removes extra global nodes
# gtm8087          [maimoneb]   test zshow "C"
# gtm8261          [partridger] test that switching NOFULL_BOOLEAN off and on does not cause an assert
# gtm5894          [base]       Test the ability to fully allocate the database file
# gtm8245          [nars]       TPFAIL uuuu in MERGE ^GBL1=^GBL2 where GBL2 contains spanning nodes
# gtm8282          [base]       Verify that the time passed in the interrupt handler counts towards the lock timeout
# rtnxfertst       [estess]     Test various control transfer methods exercising glue code routines.
# gtm8277          [shaha]      Ensure that TRIGGER -TRIG and TRIGGER -UPGRADE produce the same hash values
# gtm7949          [base]       Verify $ZHOROLOG and $ZUT display the correct time
# gtm6638          [maimoneb]   Test for dirty buffer tapering to epoch
# zwritesvn        [shaha]      Should be able to zwrite all ISVs
# gtm8317          [estess]     Testing of INVTMPDIR and INVLINKTMPDIR
# gtm8290          [nars]       SIG-11 when a routine with active breakpoints is recursively relinked
# gtm8183          [nars]       JNLBADRECFMT error when filesystem-block-size is greater than os-page-size
# gtm8240          [base]       Verfiy that setting $gtm_autorelink_ctlmax changes maximum number of autorelink routines
# gtm8332          [nars]       White-box test : Journal files can have out-of-order timestamps even if system time does not go back
# waitpid_no_timer [sopini]     Verify that waitpid does not rely on timers when they are unavailable or process is exiting.
# gtm8370          [nars]       SIG-11 from ZSHOW after a MERGE/Trigger-invocation/Runtime-error/ZGOTO sequence
# gtm8371          [nars]       SIG-11 in $QUERY(lvn) after ZSHOW "V":lvn when no variables exist
#-------------------------------------------------------------------------------------

echo "v62002 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "gtm8214 gtm8269"
setenv subtest_list_non_replic "gtm8197 gtm3912 gtm8187 gtm8167 gtm4911 gtm8241 gtm8228 gtm8087 gtm8261 gtm5894 gtm8245 gtm8282"
setenv subtest_list_non_replic " $subtest_list_non_replic rtnxfertst gtm8277 gtm7949 gtm6638 zwritesvn gtm8317 gtm8290 gtm8240"
setenv subtest_list_non_replic " $subtest_list_non_replic gtm8332 waitpid_no_timer gtm8370 gtm8371"
setenv subtest_list_replic     "gtm8183"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# gtm5894 relies on allocated disk space (using "du") which will not be accurate on compressed file systems. So skip it there.
if (1 == $is_tst_dir_cmp_fs) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm5894"
endif
# Remove rtnxfertst, gtm8290 and gtm8240 subtests from Linux-32bit and HPUX-IA64 as they involve auto-relink or recursive-relink
if ((HOST_LINUX_IX86 == "$gtm_test_os_machtype") || (HOST_HP-UX_IA64 == "$gtm_test_os_machtype")) then
        setenv subtest_exclude_list "$subtest_exclude_list rtnxfertst gtm8290 gtm8240"
endif

# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list	"$subtest_exclude_list gtm8332"
endif

# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8277 gtm7949"
else if ($?ydb_environment_init) then
	# In a YDB environment (i.e. non-GG setup), we do not have prior versions that are needed
	# by the below subtest. Therefore disable it.
	setenv subtest_exclude_list "$subtest_exclude_list gtm8277"
endif
# If the platform/host does not have GG structured build directory, disable tests that require them
if ($?gtm_test_noggbuilddir) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8087"
endif

if ($?gtm_test_temporary_disable) then
       setenv subtest_exclude_list "$subtest_exclude_list gtm8240"
endif

# Disable certain heavyweight tests on single-cpu systems
if ($gtm_test_singlecpu) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm6638"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v62002 test DONE."
