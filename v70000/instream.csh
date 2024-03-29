#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
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
# gtm9302		[estess]	Acknowledged sequence number in -SOURCE -SHOWBACKLOG and available with ^%PEEKBYNAME
# gtm9370		[estess]	Add gtm9370 to test divide-by-zero of literals is pushed to the runtime to deal with
# gtm9340		[estess]	Verify new VIEWREGLIST error is emitted when region lists specified to $VIEW() region arg
# gtm9368		[estess]	Verify a MUPIP REPLIC -SOURCE -SHUTDOWN cmd can be interrupted by ^C (terminates the wait)
# gtm9358andgtm9361	[estess]	Verify a MUPIP REPLI -SOURCE -SHUTDOWN -ZEROBACKLOG cleans up IPCs (runs as non-replic)
# gtm6952		[estess]	Test that decimal value parms can be input as hex values now.
# ydbtest530		[nars,estess]	Test the DSE DUMP -IMAGE option (debug-only so no gtm-id)
# ydb531_v6tov7		[estess]	Test the two upgrade paths (MERGE and MUPIP EXTRACT/LOAD) for V6->V7
#----------------------------------------------------------------------------------------------------------------------------------

echo "v70000 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic "gtm9370 gtm9340 gtm9358andgtm9361 ydbtest530 ydb531_v6tov7"
setenv subtest_list_replic     "gtm9302 gtm9368 gtm6952"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	# The BLOCK parameter of MUPIP JOURNAL -EXTRACT and the IMAGE parameter of DSE are only availble in a DEBUG build
	setenv subtest_exclude_list "$subtest_exclude_list ydbtest530"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if (("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) || ("HOST_LINUX_AARCH64" == $gtm_test_os_machtype)) then
	#
	# gtm9368 has very tight timing checks that don't do well on slower ARM systems where the system can go out to lunch for up to
	# a minute or more when doing dirty (UNIX) cache buffer flushing.
	#
	setenv subtest_exclude_list "$subtest_exclude_list gtm9368" # Bypass gtm9368 on all but X8664 systems
endif
if ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) then
	#
	# gtm6952 allocates 3 buffers slightly larger than 4GB (only lightly used) but since 32bit platforms cannot allocate
	# such a buffer, they cannot run this test so exclude them.
	#
	setenv subtest_exclude_list "$subtest_exclude_list gtm6952"
endif

if ($gtm_test_singlecpu) then
    setenv subtest_exclude_list "$subtest_exclude_list ydb531_v6tov7"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v70000 test DONE."
