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
#-------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------------------------------
# readonly         [nars]  Test update on database with READ_ONLY flag through multiple global directories
# ydb275socketpass [nars]  Test that LISTENING sockets can be passed through JOB or WRITE /PASS and WRITE /ACCEPT
# ydb280socketwait [nars]  Test that WRITE /WAIT on a SOCKET device with no sockets does not spin loop
# ydb282srcsrvrerr [nars]  Test that source server clears backlog and does not terminate with FILEDELFAIL or RENAMEFAIL errors
# jnlunxpcterr     [nars]  Test that MUPIP JOURNAL -EXTRACT does not issue JNLUNXPCTERR error in the face of concurrent udpates
# ydb293	   [vinay] Tests the update process operates correctly with triggers and SET $ZGBLDIR
# ydb297	   [vinay] Demonstrates LOCK commands work correctly when there are more than 31 subscripts that hash to the same value
# ydb315	   [jake]  Tests that the ZCOMPILE operation will not dispaly warning if $ZCOMPILE contains "-nowarnings"
#-------------------------------------------------------------------------------------------------------------

echo "r124 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic readonly ydb275socketpass ydb280socketwait jnlunxpcterr ydb297 ydb315"
setenv subtest_list_replic     ""
setenv subtest_list_replic     "$subtest_list_replic ydb282srcsrvrerr ydb293"

setenv subtest_exclude_list    ""
# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list ydb282srcsrvrerr"
endif

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r124 test DONE."
