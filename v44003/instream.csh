#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2003, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# ------------------------------------------------------------------------------
# for bugs fixed in V44003
# ------------------------------------------------------------------------------
# D9D06002338 [Sade]      Undefined naked global reference when string collation is used
# C9C09002134 [Nergis]    Ensure that multiple concurrent processes (mostly TP) can run in a healthy fashion
# C9C11002171 [Mohammad]  Device parameter exception=expr with open command
# D9C09002221 [Narayanan] MUPIP INTEG -TN_RESET doesn't work when current tn is > 4 billion
# C9D07002353 [zhouc] Replication logs report negative numbers in statistics
# D9D07002349 [zhouc] Cannot specify large transaction numbers in DSE
# D9D04002317 [Sam]   mprof and tptimeout needs to reset op_mprof routines
# D9C02002043 [Sade] %GI patch to handle control characters in global subscript
#             * This was originally written by sade, later added by Mohammad
# ------------------------------------------------------------------------------
#
# The first subtest to be included in subtest_list_replic below will necessitate
#	a) a change to suite.txt to enable the test to be run with replication
#	b) a change to outref.txt to handle replication as well as non-replication test runs using ##TEST_AWK macros
#
echo "V44003 test starts..."
setenv subtest_list_common ""
setenv subtest_list_replic "C9D07002353"
setenv subtest_list_non_replic "c9d06_002309 c9d06_002309_mupfndfl D9D06002338 C9C09002134 C9C11002171 D9C09002221 D9D07002349 "
setenv subtest_list_non_replic "$subtest_list_non_replic D9D04002317 D9C02002043 "
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
setenv subtest_exclude_list ""
# filter out subtests that cannot pass with MM or ASYNCIO or ENCRYPTION
# D9C09002221 Uses V4 DB which doesn't work with MM or ASYNCIO
# D9C09002221 does MUPIP set -version=V4 which is not supported by encryption binaries
if (("MM" == $acc_meth) || (1 == $gtm_test_asyncio) || ("ENCRYPT" == $test_encryption)) then
	setenv subtest_exclude_list "$subtest_exclude_list D9C09002221"
endif
$gtm_tst/com/submit_subtest.csh
echo "V44003 test DONE."
