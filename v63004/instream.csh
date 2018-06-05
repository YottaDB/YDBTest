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
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# gtm8914	    [jake]  Tests that $VIEW("GVSTATS",<region>) ZSHOW "G" and ZSHOW "T" append output with "?" for processes w/o access to the current shared statistics
# gtm8909	    [jake]  Tests that <ctrl-c> within the help facility no longer leads to EN0256 error upon exit
# gtm8874	    [jake]  Tests the VIEW command's [:<region list>] qualifier
# gtm8860	    [jake]  Tests that journal extract removes additional / from journal and output file paths
# gtm8791	    [jake]  Tests that <ctrl-z> no longer causes segmentation violation
# gtm8699	    [jake]  Tests that $VIEW("STATSHARE",<region>) returns 1 if the process is sharing DB stats and 0 otherwise
# gtm8202	    [jake]  Tests the functionality of the -SEQNO qualifier for the mupip journal -extract command
# gtm5730	    [jake]  Tests that the update process now logs record types with a corresponding, non-numerical, description
# gtm1042	    [jake]  Tests the that env variable gtm_mstack_size sets the size of the M stack as expected
# gtm8891	    [vinay] Tests that <side-effect-expression><pure-Boolean-operator>$SELECT(0:side-effect-expression)) sequence produces a SELECTFALSE runtime error
# gtm8894	    [vinay] Tests that $zreldate outputs in the form YYYYMMDD 24:60
# gtm8643	    [jake]  Tests that YDB no longer enforces queue depth limit of 5 for SOCKET devices.
# gtm8922	    [jake]  Tests the functionality of VIEW keywords that take <region-list> expressions
# gtm8923	    [jake]  Tests the READ * and WRITE * commands no longer produce errors or incorrect output for files or sockets with CHSET={UTF-16,UTF-16BE,UTF-16LE}
# gtm8903	    [jake]  Tests $SELECT(1:,:) function call for errors when global references are present

echo "v63004 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8914 gtm8909 gtm8874 gtm8860 gtm8791 gtm8699 gtm8202 gtm1042 gtm8891 "
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8894 gtm8643 gtm8922 gtm8923 gtm8903"
setenv subtest_list_replic     ""
setenv subtest_list_replic     "$subtest_list_replic gtm5730"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63004 test DONE."
