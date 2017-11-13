#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Part D of supplementary instances test - original suppl_inst test split into multiple tests for quicker run times of each test
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# fetchresync_supplgroup	[bahirs] <Test fetchresync rollback supplementary group member>
# noresync_1			[bahirs] <Test noresync qualifier for receiver start-up.>
# overwrite_stream_info		[parentel,kishore] <Test overwriting of stream info by updateresync.>
# supplgrouprepl		[bahirs] <Test robustness of P->Q replication in case of multiple switch-ver between A and B>
# updateresync_pp		[kishoreh] Test of -updateresync on a supplementary propagating primary instance.
# upgrade_inst1			[bahirs] <Test the upgrade of P(non-supplementary instace) from B(supplementary instance)
# pqqp				[kishoreh] Test switching of INST1 -> INST3 -> INST4 to INST1 -> INST4 -> INST3

echo "Part D of supplementary instances test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_replic     "fetchresync_supplgroup noresync_1 overwrite_stream_info supplgrouprepl updateresync_pp upgrade_inst1 pqqp"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
# updateresync_pp copies mumps.repl across instances and starts replication server. Since copying .repl file across endian, 32/64bit machines won't work.
if ("MULTISITE" == "$test_replic") then
	setenv subtest_exclude_list "$subtest_exclude_list updateresync_pp "
endif

# Disable certain heavyweight tests on single-cpu systems
if ($gtm_test_singlecpu) then
	setenv subtest_exclude_list "$subtest_exclude_list fetchresync_supplgroup"
endif

# Randomization of replication type is disable since it is all handled by the subtests.
setenv test_replic_suppl_type 0

# Do not exceed more than 128 (16 on AIX) MB align size as it otherwise may exhaust the memory (see <central_mem_exhausted_align>).
if ("AIX" == $HOSTOS) then
	@ align_limit = 32768
else
	@ align_limit = 262144
endif
if ($test_align > $align_limit) then
    setenv test_align $align_limit
    setenv tst_jnl_str `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
    echo "# Make sure align size is less than $align_limit" >>&! settings.csh
    echo "setenv test_align $test_align"	      >>&! settings.csh
    echo "setenv tst_jnl_str $tst_jnl_str"            >>&! settings.csh
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "Part D of supplementary instances test DONE."
