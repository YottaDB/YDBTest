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
# gtm9213	[estess]	Verify a process can SET the trailing portion of $SYSTEM
# gtm8010	[estess]	Test that 128-255 byte EXCEPTION parm on OPEN of /dev/null operates correctly
# gtm9452	[sam,hoyt]	CLOSE deviceparameter REPLACE overwrites an existing file, which RENAME does not
# gtm8681	[estess]	Verify MUPIP BACKUP -RECORD stores the time of its start when it completes successfully
# gtm4814	[estess]	Verify M-profiling (VIEW "TRACE") restored after ZSTEP
# gtm4272       [estess]	Verify that MUPIP BACKUP displays information in standard GT.M messages format
# gtm9057	[estess]	Verify MUPIP JOURNAL -EXTRACT output can be sent to a FIFO device
# gtm9451	[nars]		Verify LOCKSPACEFULL in final retry issues TPNOTACID and releases crit
# gtm9131	[nars]		Verify TPRESTART messages properly identifies statsdb extension related restarts
# gtm9388	[estess]	Verify ZSHOW "B" when ZBREAK used with no or null action argument displays correctly
# gtm9443	[nars]		Verify MUPIP SET JOURNAL more cautious with journal file chain
#----------------------------------------------------------------------------------------------------------------------------------

echo "v70001 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"gtm9213 gtm8010 gtm9452 gtm8681 gtm4814 gtm9057 gtm9451 gtm9131 gtm9388 gtm9443"
setenv subtest_list_replic	"gtm4272"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Disable gtm9131 subtest on ARM as it is a heavyweight test (spawns off 512 processes)
if (("armv6l" == `uname -m`) || ("aarch64" == `uname -m`)) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm9131"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v70001 test DONE."
