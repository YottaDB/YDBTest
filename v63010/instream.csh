#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#----------------------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# gtm9206		[bdw]		 Test that MUPIP LOAD can correctly handle 64 bit values for -begin and -end
# gtm9188		[bdw]		 Test that $ZCMDLINE is set correctly for mumps -run and mumps -direct commands with extra spaces
# gtm9190		[estess]	 Test that eu-elflint approves of M generated object files
# gtm9183		[estess]	 Test that indirect exclusive NEW after FOR (on same line) does not cause sigsegv or other error
# gtm9180		[bdw]		 Look for error message if block number for DSE -add or -dump command doesn't fit in a 32 bit signed integer
# gtm9181		[estess]	 Add boolean literal tests that failed prior to V63010 with some involving $SELECT()
# gtm9076		[bdw]		 Look for error messages for GDE, MUPIP CREATE and journal files when file path exceeds 255 characters
# gtm9178		[bdw]		 Tests that a $ztimeout run from direct mode produces a ERRWZTIMEOUT instead of a GTMASSERT2 on executing a runtime error
# gtm9166		[bdw]		 Test for JNLPROCSTUCK message in syslog instead of JNLFLUSH when journal file writes take too long
# gtm8747		[bdw]		 Test that a MUPIP JOURNAL -EXTRACT can extract journal records using -CORRUPTDB even if the database no longer exists
# gtm8322		[bdw]		 Tests that MUPIP SIZE -SUBSCRIPT works as expected
# gtm1044		[bdw]		 Tests $ZATRANSFORM with optional 3rd arguments 2 and -2.
#----------------------------------------------------------------------------------------------------------------------------------------------------------------


echo "v63010 test starts..."

# List the subtests seperated by sspaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic "gtm9206 gtm9188 gtm9190 gtm9183 gtm9180 gtm9181 gtm9076 gtm9178 gtm9166 gtm8747 gtm8322 gtm1044"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list gtm9166"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63010 test DONE."
