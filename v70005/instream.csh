#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
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
# strcat_efficiency-gtmf135278    [berwyn] Test the new string pool concatenation optimisations
# trigger_stats-gtm135406         [berwyn] Test the new trigger stats feature of v70005
# audit_lke_facility-gtmf135370   [ern0]   Test Audit LKE facility
# audit_dse_facility-gtmf135383   [ern0]   Test Audit DSE facility
# namelevel_zprevious-gtmde327593 [nars]   Test that name-level $zprevious does not return input global name
#----------------------------------------------------------------------------------------------------------------------------------

echo "v70005 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_non_replic	"$subtest_list_non_replic strcat_efficiency-gtmf135278"
setenv subtest_list_non_replic	"$subtest_list_non_replic trigger_stats-gtmf135406"
setenv subtest_list_non_replic	"$subtest_list_non_replic audit_lke_facility-gtmf135370"
setenv subtest_list_non_replic	"$subtest_list_non_replic audit_dse_facility-gtmf135383"
setenv subtest_list_non_replic	"$subtest_list_non_replic namelevel_zprevious-gtmde327593"
setenv subtest_list_replic	""

if ($?test_replic) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Add tests to space-separated $subtest_exclude_list to disable them, e.g. on a particular host or OS
setenv subtest_exclude_list ""

# Only run tests that use perf if perf exists and db is not an asan build (slow)
set perf_missing = `which perf >/dev/null; echo $status`
source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# detect asan build into $gtm_test_libyottadb_asan_enabled
if ($perf_missing || $gtm_test_libyottadb_asan_enabled) then
	setenv subtest_exclude_list "$subtest_exclude_list strcat_efficiency-gtmf135278"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v70005 test DONE."
