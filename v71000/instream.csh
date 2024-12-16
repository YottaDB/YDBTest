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
#----------------------------------------------------------------------------------------------------------------------------------

echo "v71000 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"lockargs_identical-gtmde340906"
setenv subtest_list_non_replic	"numoflow_exponential-gtmde388565"
setenv subtest_list_non_replic	"fallintoflst_warning-gtmde376239"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

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
