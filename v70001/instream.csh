#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
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
# gtm9429	[estess]	Verify features such as $QLENGTH() and $QSUBSCRIPT() do tighter checking for canonic references
# gtm9437	[nars]		Verify USE ATTACH and USE DETACH issue error if additional device parameters are specified
# gtm9424	[nars]		Verify various MUPIP BACKUP enhancements/changes in V7.0-001
# gtm9422	[estess]	Verify toggle stats converted to counters
# gtm9423	[estess]	Verify MUPIP DUMPFHEAD recognizes the -FLUSH qualifier
# gtm9410	[nars]		Verify %SYSTEM-E-ENO2 from concurrent GDE invocations AND GLD creation does not sleep unnecessarily
# gtm9409	[nars]		Verify JOBFAIL error due to socketpair setup issues reports the underlying cause
# gtm9400	[nars]		Verify that MUPIP STOP on MUPIP REORG does not result in KILLABANDONED integ error
# gtm9392	[nars]		Verify that NOISOLATION is correctly maintained even if gld/db have differing max-key-size
# gtm9382	[nars]		Verify that GTMSECSHRPERM error is not issued if gtm_dist is a symbolic link and read-only db
# gtm9373	[nars]		Verify SRCBACKLOGSTATUS and LASTTRANS messages in MUPIP REPLICATE -SOURCE -SHOWBACKLOG
#----------------------------------------------------------------------------------------------------------------------------------

echo "v70001 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"gtm9213 gtm8010 gtm9452 gtm8681 gtm4814 gtm9057 gtm9451 gtm9131 gtm9388 gtm9443 gtm9429"
setenv subtest_list_non_replic	"$subtest_list_non_replic gtm9437 gtm9424 gtm9422 gtm9423 gtm9410 gtm9409 gtm9400 gtm9392"
setenv subtest_list_non_replic	"$subtest_list_non_replic gtm9382"
setenv subtest_list_replic	"gtm4272 gtm9373"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list gtm9409"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if (("armv6l" == `uname -m`) || ("aarch64" == `uname -m`)) then
	# Disable gtm9131 subtest on ARM as it is a heavyweight test (spawns off 512 processes)
	setenv subtest_exclude_list "$subtest_exclude_list gtm9131"
	# Disable gtm9373 subtest on ARM as it is a timing-sensitive test
	setenv subtest_exclude_list "$subtest_exclude_list gtm9373"
endif

# Disable gtm9422 subtest on ARM as it produces inconsistent results (failing nearly every run)
# due to test timing and multiple processes and stats gathering where some stats stay zero
# for the test duration (15 seconds).
if ("armv6l" == `uname -m`) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm9422"
endif


# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v70001 test DONE."
