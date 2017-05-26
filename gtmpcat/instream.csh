#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
#
# basic		[estes]		Tests the basic capabilities of gtmpcat under all available versions
#
# Environment vars that can affect these tests:
#
# $gtmpcat_keep_cores    - If set (to anything), does not delete the cores created by each new version. Make sure LOTS of disk
#                          space is available. Can exceed 16GB (as of V60001). Note all cores are pulled into the main test
#			   directory (i.e. out of repl2ndary dir) and renamed as
#			        gtmpcat-{mumpsdmp|mupipdmp}-{primary|secondary}.{$version}.{$corename}
# $gtmpcat_test_versions - If set, the list of space separated versions is tested instead of all existing production versions
#                          available on the box. Note whatever version the test is run with is used for all gtmpcat invocations
#			   regardless of what version created the core and the running version is added to the test list if it
#			   is not already on the list. So a test submitted with V990 and targeting V54000 tests both V54000 and V990.
# $gtmpcat_nomprof       - If set (to anything), the usual practice of enabling M-Profiling (only) for the test submission version
#                          is bypassed avoiding all M-Profiling.
#
#-------------------------------------------------------------------------------------

echo "gtmpcat test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "basic"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use sed filters to remove subtests that are to be disabled on a particular host or OS

# Make sure no dynamic literals as many versions don't support them and this test runs LOTS of versions
setenv gtm_test_dynamic_literals "NODYNAMIC_LITERALS"
# Again, many versions don't support embed_source. Disable it.
setenv gtm_test_embed_source "FALSE"
# $gtmcompile is already set with these so undo it as well
unsetenv gtmcompile

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "gtmpcat test DONE."
