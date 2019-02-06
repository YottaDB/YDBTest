#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2019 YottaDB LLC. and/or its subsidiaries. #
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
# gds_max_blk	[s7kr] Testing GDS max number of blocks to 224M and for older V5 version, test for 128M blocks.
# ossmake	[shaha] Test the makefile builds regularly so that we know when they break
# maxtrignames	[shaha] Test that adds 999,999 triggers with auto generated names
# gtm8416	[partridger] Verify 1 second HANG between global SETs ensures that each journal record falls in a different second
#				The above test is manually started because takes a long time, but it's not computationally intensive
# sem_counter	[base]  Launch over 32K processes and ensure they can connect to the database if -qdbrundown is on
# ydb395	[quinn] Test that /tmp/yottadb/$ydb_ver has read-write-execute permissions for all users permitted to execute YottaDB
#				The above test is manually started because it needs standalone access to the /tmp directory
#
setenv subtest_list_common "4g_journal align_string"
setenv subtest_list_non_replic "4g_dbcertify alsmemleak largelibtest gds_max_blk maxtrignames ossmake"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8416 sem_counter ydb395"
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

# Disable largelibtest subtest on hosts that do not have an SSD.
# On HDD, it takes many hours to finish that the TEST-E-HANG alert kicks in.
if (! $is_tst_dir_ssd) then
	setenv subtest_exclude_list "$subtest_exclude_list largelibtest"
else if (0 == $big_files_present) then
	# $gtm_test/big_files directory is not present. So exclude this subtest as it needs files from there.
	setenv subtest_exclude_list "$subtest_exclude_list largelibtest"
else if ($gtm_platform_size != 64) then
	## Disable largelibtest on non-64-bit machines
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
endif

if ($?ydb_test_exclude_sem_counter) then
	if ($ydb_test_exclude_sem_counter) then
		# An environment variable is defined to indicate the below subtest needs to be disabled on this host
		setenv subtest_exclude_list "$subtest_exclude_list sem_counter"
	endif
endif

$gtm_tst/com/submit_subtest.csh
echo "Manually_Start tests DONE."
