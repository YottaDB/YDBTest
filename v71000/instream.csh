#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
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
# lockargs_identical-gtmde340906	[jon]	Attempting a LOCK with more identical arguments than GT.M supports for the command generates an error
# numoflow_exponential-gtmde388565	[jon]	Avoid inappropriate NUMOFLOW from a literal Boolean argument with exponential (E) form
# fallintoflst_warning-gtmde37623	[jon]	When GT.M inserts an implicit QUIT to prevent a possible error, it generates a FALLINTOFLST WARNING message
# commandlen_parse-gtmde422089		[jon]	Test ARGSLONGLINE (LINETOOLONG) error reporting in utility commands
# lockargs_identical-gtmde340906	[jon]	Attempting a LOCK with more identical arguments than GT.M supports for the command generates an error
# mupipbackup_fastercopy-gtmde408789	[jon]	MUPIP BACKUP -DATABASE uses faster copy mechanism when available
# rctldump_superseded-gtmf135385	[jon]	MUPIP RTCLDUMP reports the number of times a routine has been replaced (rtnsupersede) in the autorelink cache
#----------------------------------------------------------------------------------------------------------------------------------

echo "v71000 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"lockargs_identical-gtmde340906"
setenv subtest_list_non_replic	"numoflow_exponential-gtmde388565"
setenv subtest_list_non_replic	"fallintoflst_warning-gtmde376239"
setenv subtest_list_non_replic	"commandlen_parse-gtmde422089"
setenv subtest_list_non_replic	"mupipbackup_fastercopy-gtmde408789"
setenv subtest_list_non_replic	"rctldump_superseded-gtmf135385"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Skip the mupipbackup_fastercopy-gtmde408789 subtest when the test output directory and /tmp
# have the same filesystem types, as this can cause test failures due to the following reasons:
# 1. Per the reasoning at `v70001/u_inref/gtm9424.csh`, running the test when the test output
# directory and /tmp have the same filesystem types would lead to an EXDEV error, specifically
# in GT.M versions prior to V71000.
# 2. According to the GT.M version V71000 release note, MUPIP BACKUP -ONLINE no longer retries
# backups for "certain errors", i.e. EXDEV errors.
# 3. Consequently, MUPIP BACKUP -ONLINE will not retry in the case where the test directory
# and /tmp have the same filesystem type.
# 4. Finally, it is not possible to control for the output differences in the outref file,
# since SUSPEND_OUTPUT doesn't support filesystem comparisons.
if ($tst_dir_fstype == $tmp_dir_fstype) then
	setenv subtest_exclude_list "$subtest_exclude_list mupipbackup_fastercopy-gtmde408789"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v71000 test DONE."
