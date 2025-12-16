#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2025 YottaDB LLC and/or its subsidiaries.  #
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
######################################################################
# manually_start.csh                                                 #
# all subtests in this test are automated, but won't run as part of  #
# the daily/weekly cycle. The tests here will be started manually in #
# a controlled fashion, e.g. during the regression testing phase for #
# a major release.                                                   #
######################################################################
#
# gds_max_blk	[s7kr] Testing GDS max number of blocks for V6 mode blocks (992M blocks) and V7 mode blocks (~16GB blocks)
# ossmake	[shaha] Test the makefile builds regularly so that we know when they break
# maxtrignames	[shaha] Test that adds 999,999 triggers with auto generated names
# gtm8416	[partridger] Verify 1 second HANG between global SETs ensures that each journal record falls in a different second
#				The above test is manually started because takes a long time, but it's not computationally intensive
# sem_counter	[base]  Launch over 32K processes and ensure they can connect to the database if -qdbrundown is on
#
setenv subtest_list_common ""
setenv subtest_list_common "$subtest_list_common 4g_journal"
setenv subtest_list_common "$subtest_list_common align_string"
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic 4g_dbcertify"
setenv subtest_list_non_replic "$subtest_list_non_replic alsmemleak"
setenv subtest_list_non_replic "$subtest_list_non_replic largelibtest"
setenv subtest_list_non_replic "$subtest_list_non_replic gds_max_blk"
setenv subtest_list_non_replic "$subtest_list_non_replic maxtrignames"
setenv subtest_list_non_replic "$subtest_list_non_replic ossmake"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8416"
setenv subtest_list_non_replic "$subtest_list_non_replic sem_counter"
setenv subtest_list_replic ""

if ($?test_replic == 1) then
	if ($gtm_test_tp == "TP" ) then
		setenv subtest_list_common "$subtest_list_common dual_fail2_no_ipcrm1 dual_fail2_no_ipcrm2 dual_fail3_nonsym"
	else
		setenv subtest_list_common "$subtest_list_common"
	endif
	setenv subtest_list "$subtest_list_replic $subtest_list_common"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# EXCLUSIONS
setenv subtest_exclude_list ""

## Disable align_string testing until string alignment is handled completely
setenv subtest_exclude_list "$subtest_exclude_list align_string"

# Disable ossmake as that requires a GT.M development environment setup
# Besides, YottaDB builds are always cmake builds so no special need for this test like is the case with GT.M who
# have a different in-house build compared to the cmake build.
setenv subtest_exclude_list "$subtest_exclude_list ossmake"

# Disable gds_max_blk subtest on hosts that do not have an SSD.
# On HDD, a simple MUPIP INTEG on the 20TB database takes hours to finish that the TEST-E-HANG alert kicks in.
if (! $is_tst_dir_ssd) then
	setenv subtest_exclude_list "$subtest_exclude_list gds_max_blk"
endif

source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# defines "gtm_test_libyottadb_asan_enabled" env var

# Disable largelibtest subtest on hosts that do not have an SSD.
# On HDD, it takes many hours to finish that the TEST-E-HANG alert kicks in.
if (! $is_tst_dir_ssd) then
	setenv subtest_exclude_list "$subtest_exclude_list largelibtest"
else if (0 == $big_files_present) then
	# $gtm_test/big_files directory is not present. So exclude this subtest as it needs files from there.
	setenv subtest_exclude_list "$subtest_exclude_list largelibtest"
else if ("HOST_LINUX_X86_64" != $gtm_test_os_machtype) then
	# Disable largelibtest on non-x86_64 machines. On even the fastest in-house ARM machines, this test
	# can run for hours just to create the shared libraries and then is going to need more than 4GB of memory
	# which can easily swamp the system.
	setenv subtest_exclude_list "$subtest_exclude_list largelibtest"
else if ($gtm_test_libyottadb_asan_enabled) then
	# Disable largelibtest if ASAN is ON. This is because creating the shared libraries with ASAN has been seen to
	# take as much as 10 hours even on reasonably fast systems. The same subtest has been seen to run in 1 hour on
	# the same system. It is not clear exactly what combination of random settings (from the test framework) causes
	# the huge slowdown. but every long test run has been seen with ASAN:1 random setting. It is not surprising since
	# there is gigabytes of memory involved in the shared library and ASAN is going to do memory checks on all of that.
	# It is not considered worth testing this subtest with ASAN given the huge runtime it entails.
	setenv subtest_exclude_list "$subtest_exclude_list largelibtest"
endif

## Disable 4g_dbcertify on platforms without a V4 version
if ($?gtm_platform_no_V4) then
	setenv subtest_exclude_list "$subtest_exclude_list 4g_dbcertify"
endif

# Disable heavyweight subtests on ARM platform as it takes a long time to run.
# Also disable these subtests on 1-CPU boxes as it would take a long time to run.
# The test mostly exercises portable code so it is okay if only multi-CPU x86_64 boxes runs these tests.
if ($gtm_test_singlecpu || ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype)) then
	setenv subtest_exclude_list "$subtest_exclude_list alsmemleak maxtrignames"
else if ($gtm_test_libyottadb_asan_enabled) then
	# We have seen ASAN (in both PRO and DBG builds) cause the "alsmemleak" subtest to run for many hours
	# on even the faster x86_64 systems triggering a HANG/TIMEDOUT email alert and false failures.
	# So disable this subtest in that case.
	setenv subtest_exclude_list "$subtest_exclude_list alsmemleak"
endif
if ($gtm_test_singlecpu) then
	if ($?test_replic == 1) then
		# Exclude heavyweight 4g_journal subtest on 1-CPU systems in -replic mode.
		# This frequently times out as it takes more than 24 hours to finish.
		setenv subtest_exclude_list "$subtest_exclude_list 4g_journal"
	endif
endif

if ($?ydb_test_exclude_sem_counter) then
	if ($ydb_test_exclude_sem_counter) then
		# An environment variable is defined to indicate the below subtest needs to be disabled on this host
		setenv subtest_exclude_list "$subtest_exclude_list sem_counter"
	endif
endif

if ($gtm_test_libyottadb_asan_enabled) then
	# libyottadb.so was built with address sanitizer
	# The below subtest spawns 34,000 processes which causes memory issues on the system (64Gb of RAM and
	# 64Gb of swap get used 100% and not enough for the test) whereas without ASAN less than half of that RAM gets used.
	# The cause of this is suspected to be the shadow memory that ASAN uses to track memory leaks etc.
	# Not much can be done to avoid that overhead. Therefore disable this test if ASAN is enabled.
	setenv subtest_exclude_list "$subtest_exclude_list sem_counter"
endif

$gtm_tst/com/submit_subtest.csh
echo "Manually_Start tests DONE."
