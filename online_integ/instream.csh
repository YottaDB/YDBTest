#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
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
# ointeg1    [maimoneb] test basic snapshot functionality
# ointeg2    [maimoneb] test that db with V4 blocks gets error
# ointeg3    [maimoneb] test incorrectly marked free and doubly allocated blocks detected
# ointeg4    [maimoneb] test multiple concurrent updaters
# ointeg5    [maimoneb] test when unable to create snapshot file(s)
# ointeg6    [s7kk]     test online integ with encryption
# ointeg8    [s7kk]     test that kill is handled properly including during rundown
# ointegcli  [maimoneb] command line parameter combinations
# 4GBOLI     [maimoneb] test >4GB database and multiple simultaneous snapshots
# ointegbkg  [maimoneb] run OLI in the background, e.g., for profile perf test
# ointeg9    [s7kk]	run OLI in the background on a WorldVista DB and issue Kill -15 to ensure cleanup is done
# fast_integ [zouc]	Test the snapshot file writing when fast integ is running
echo "online_integ test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ointeg1 ointeg2 ointeg3 ointeg5 ointeg6 ointeg8 ointegcli 4GBOLI ointeg9 fast_integ"
setenv subtest_list_replic     "ointeg4"

# Use subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list ""

# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list ointeg1 ointeg6 ointeg8 fast_integ"
endif

set rand = `$gtm_exe/mumps -run rand 2`
if (1 == $rand) then
	setenv FASTINTEG " -fast "
else
	setenv FASTINTEG ""
endif

if ("dbg" == "$tst_image") then
#	filter out test that cores in dbg (from intentionally introduced error)
	setenv subtest_exclude_list "$subtest_exclude_list ointeg3"
#	Determine offset to field in (node local) that is used to synchronize GT.M and the test system
	$gtm_tools/offset.csh node_local gtm_main.c >&! offset.out
	setenv hexoffset `$grep -w wbox_test_seq_num offset.out | sed 's/\].*//g;s/.*\[0x//g'`
	echo $hexoffset >! hexoffset.out
endif

# Filter out ointeg2 since it requires a V4 database (which does not support MM or encryption or ASYNCIO)
#   ointeg9 and 4GBOLI tests use 4G VistA database that is created without encryption and so does
#   not make sense to run these tests with encryption. Moreover, there are asserts in db_init
#   which get triggered if the global directory indicates encryption is OFF but database indicates
#   encryption is ON.
if (("MM" == "$acc_meth") || ("ENCRYPT" == "$test_encryption") || (1 == "$gtm_test_asyncio") || 1) then
	setenv subtest_exclude_list "$subtest_exclude_list ointeg2"
else
	# The below subtest uses MUPIP SET -VERSION which is not supported in GT.M V7.0-000 (YottaDB r2.00). Therefore disable it for now.
	setenv subtest_exclude_list "$subtest_exclude_list ointeg2"	# [UPGRADE_DOWNGRADE_UNSUPPORTED]
endif

if ("ENCRYPT" == "$test_encryption") then
	setenv subtest_exclude_list "$subtest_exclude_list 4GBOLI ointeg9"
endif

# filter out ointeg6 since it requires encryption (and encryption is not supported with MM)
if (("MM" == "$acc_meth") || ("NON_ENCRYPT" == "$test_encryption")) then
	setenv subtest_exclude_list "$subtest_exclude_list ointeg6"
endif

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

if ($LFE == "L") then
	setenv subtest_exclude_list "$subtest_exclude_list 4GBOLI"
endif

if ($?gtm_test_temporary_disable) then
	# All of the below need $gtm_test/big_files/online_integ/
	setenv subtest_exclude_list "$subtest_exclude_list 4GBOLI ointeg9"
endif

# default to V5 database (ointeg2 will change to V4) and randomly enable journalling
setenv gtm_test_mupip_set_version "disable"
source $gtm_tst/com/set_env_random.csh gtm_test_jnl

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "online_integ test DONE."
