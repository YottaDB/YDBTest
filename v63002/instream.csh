#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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
# gtm8694	    [vinay] Tests YDB's mechanism to restrict certain facilities
# gtm8281	    [vinay] Tests YottaDB source lines, XECUTE strings and Direct Mode input all accept up to 8192 byte values
# gtm5178	    [vinay] Tests YottaDB reports BLKTOODEEP errors as warnings
# gtm8717	    [vinay] Tests $select properly handles certain syntax errors that would normally produce fatal errors
# gtm8644	    [vinay] Tests that ZSYSTEM invokes the shell specified by the SHELL environment variable, and the new nested quotes system
# gtm8760	    [vinay] Tests YottaDB properly handles environment variables whose contesnts are over 32K in size
# gtm5250	    [vinay] Tests YottaDB supports fractional timeouts
# gtm8736	    [vinay] Tests $zroutines defaults to "." when $gtmroutines is undefined
# gtm8698	    [vinay] Tests YottaDB issues a MUCREFILERR in the syslog identifying the application code entryref when it encounters an error creating an AutoDB Database
# gtm8711	    [vinay] Tests GDE appropriately maintains return status when invoked from the shell
# gtm8733	    [vinay] Tests $ZCONVERT operates appropriately in UTF-8 NOBADCHAR mode
# gtm8718	    [vinay] Tests setting $ZROUTINES to an invalid string leaves the previous value of $ZROUTINES as it is
# gtm8616	    [vinay] Tests argumentless MUPIP RUNDOWN logs a message in the syslog containing the pid, uid and current working directory
# gtm8740	    [vinay] Tests custom error files can be loaded without a full shutdown
# gtm8766	    [vinay] Tests MUPIP and GDE behave appropriately when trying to set global buffer values too high
#-------------------------------------------------------------------------------------

echo "v63002 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm8694 gtm8281 gtm5178 gtm8717 gtm8644 gtm8760 gtm5250 gtm8736 gtm8698 gtm8711 gtm8733 gtm8718 gtm8616 gtm8766"
setenv subtest_list_replic     "gtm8740"


if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63002 test DONE."
