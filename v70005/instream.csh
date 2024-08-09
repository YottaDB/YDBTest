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
# stack_over-gtmf135319           [berwyn] Tests for correct error when a single operation exceeds both STACKCRIT and STACKOFLOW
# audit_gde_facility-gtmf135382	  [ern0]   Test Audit GDE facility
# zauditlog-gtmf170998            [ern0]   Test $ZAUDITLOG() function for possible application audit logging, and audit GDE facility
# audit_mupip_facility-gtmf188829 [ern0]   Test Audit MUPIP facility
# online_integ_shmid-gtmde326986  [nars]   Test that relatively idle GT.M processes detach from snapshot shmid in a timely fashion
# backup_tmpfile-gtmde340860      [nars]   Test that MUPIP BACKUP cleans up temporary files when multi-region backup copy errors
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
setenv subtest_list_non_replic	"$subtest_list_non_replic stack_over-gtmf135319"
setenv subtest_list_non_replic	"$subtest_list_non_replic audit_gde_facility-gtmf135382"
setenv subtest_list_non_replic	"$subtest_list_non_replic zauditlog-gtmf170998"
setenv subtest_list_non_replic	"$subtest_list_non_replic audit_mupip_facility-gtmf188829"
setenv subtest_list_non_replic	"$subtest_list_non_replic online_integ_shmid-gtmde326986"
setenv subtest_list_non_replic	"$subtest_list_non_replic backup_tmpfile-gtmde340860"

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

# Skip the backup_tmpfile-gtmde340860 subtest test for the exact same conditions that "Test (1c)" is skipped in
# "v70001/u_inref/gtm9424.csh" since both try to recreate the EXDEV error. The below logic is copied over from there.
set exclude_backup_tmpfile_subtest = 1
if (($ydb_test_copy_file_range_avail) && (("ubuntu" != $gtm_test_linux_distrib) || ("20.04" != $gtm_test_linux_version))) then
	if (($tst_dir_fstype != $tmp_dir_fstype) && ("armv6l" != `uname -m`) && ("aarch64" != `uname -m`)) then
		set exclude_backup_tmpfile_subtest = 0
	endif
endif
if ($exclude_backup_tmpfile_subtest) then
	setenv subtest_exclude_list "$subtest_exclude_list backup_tmpfile-gtmde340860"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v70005 test DONE."
