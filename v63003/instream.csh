#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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
# gtm8788           [nars]  Test that BLKTOODEEP error lines are excluded from object file (GTM-8788 fixed in GT.M V6.3-003)
# gtm7986	    [vinay] Test that a line of over 8192 bytes produces an LSINSERTED warning
# gtm8186	    [vinay] Test DO, GOTO and ZGOTO can take offset without a label
# gtm8804	    [vinay] Test zshow "t" produces only a summary of zshow "g" and "l"
# gtm8832	    [vinay] Test string literal evaluating to >=1E47 produces a NUMOFLOW error
# gtm8617	    [vinay] Tests MUPIP SET command of STDNULLCOLL and NULL_SUBSCRIPTS
# gtm4212	    [vinay] Tests that MUPIP BACKUP produces a FILENAMETOOLONG error for paths >=255 characters
# gtm8732nr	    [vinay] Tests the valid inputs of the flag DEFER_TIME for the MUPIP SET command
# gtm8732r	    [vinay] Tests the valid inputs of HELPERS and LOG_INTERVAL for the MUPIP REPLICATE command
# gtm8767	    [vinay] Tests the functionality of HARD_SPIN_COUNT, SPIN_SLEEP_MASK and SPIN_SLEEP_LIMIT for MUPIP SET
# gtm8735	    [vinay] Tests the functionality of the READ_ONLY flag in MUPIP SET
# gtm8779	    [vinay] Tests changing Freeze produces a DBFREEZEON/DBFREEZEOFF message in the system
# gtm8798	    [vinay] Tests ENDIANCVT converts the mutex fields
# gtm8846	    [vinay] Tests Mupip Set Journal appropriately handles a file with excess slashes
# gtm8780	    [vinay] Tests $SELECT() produces a syntax error for an omitted colon after a literal true argument
# gtm8787	    [vinay] Tests Mupip Journal -Extract=-stdout properly handles its termination
# gtm8889	    [vinay] Tests zhelp does not produce an error when <Ctrl C> is pressed
# gtm8856	    [vinay] Tests literal optimizations that can result in errors at compile time are deferred if done inside XECUTE
# gtm8857	    [vinay] Tests patterns exceeding the size GTM supports produces a PATMAXLEN error
# gtm8854	    [vinay] Tests syntax error in the argument of a FALSE postconditional is handled appropriately
# gtm8795	    [vinay] Tests journal files update after MUPIP FREEZE -ON -ONLINE
# gtm8839	    [vinay] Tests $DEVICE returns the complete error message
# gtm8781	    [vinay] Tests ZSYSTEM does not produce memory leaks
# gtm8849	    [vinay] Shows help databases have QDBRUNDOWN and NOGVSTATS characteristics
# gtm8794	    [vinay] Tests copies of a database file can be used after a MUPIP RUNDOWN -OVERRIDE and MUPIP FREEZE -OFF on the copy
# gtm8790	    [vinay] Tests $REFERENCE will maintain extended reference for the first reference when stat sharing is enabled
# gtm8587	    [vinay] Tests $KEY is maintained for sequential devices and $DEVICE is maintained for certain error descriptions
# gtm8855	    [vinay] Tests GTM correctly cleans up buffers allocated due to a missing global directory
# gtm8850	    [vinay] Tests GTM processes properly detach from a database when a FREEZE -ONLINE is in place
# gtm8847	    [vinay] Tests the functionality of $ZSTRPLLIM
# gtm8801	    [vinay] Tests ^%YGBLSTAT works on a cmake build
# gtm8842	    [vinay] Tests TRIGGER_MOD appropriately restricts ZBREAK and ZSTEP
#-------------------------------------------------------------------------------------

echo "v63003 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm8788 gtm7986 gtm8186 gtm8804 gtm8832 gtm8617 gtm4212 gtm8732nr gtm8767 gtm8735 gtm8779 gtm8798"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8846 gtm8780 gtm8787 gtm8889 gtm8856 gtm8857 gtm8854 gtm8795 gtm8839"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8781 gtm8849 gtm8794 gtm8790 gtm8587 gtm8855 gtm8850 gtm8847 gtm8801 gtm8842"
setenv subtest_list_replic     "gtm8732r gtm8795 gtm8794"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list gtm8839"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63003 test DONE."
