#!/usr/local/bin/tcsh -f
#################################################################
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
#---------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------------------------------
# ydb854 [nars]   Test that ICUSYMNOTFOUND error using Simple API does not assert fail
# ydb860 [nars]   Test various code issues identified by fuzz testing
# ydb861 [estess] Test $ZATRANSFORM() returns correct value for 2/-2 3rd parm and does not sig-11 with computed input values
# ydb869 [nars]   Test boolean expressions involving huge numeric literals issue NUMOFLOW error (and not SIG-11)
# ydb872 [nars]   Test GTMASSERT2 fatal error no longer occurs when lots of short-lived processes open/close relinkctl files
# ydb864 [bdw]    Test online and -noonline MUPIP BACKUPs with path lengths from 220 to 265
# ydb888 [sam]    Test $ZGLD is a valid synonym for $ZGBLDIR
# ydb901 [nars,sam] SIG-11 when compiling with -NOLINE_ENTRY if M code contains a BREAK
# ydb919 [nars]   Test %ZMVALID M utility routine
#----------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r136 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ydb854 ydb860 ydb861 ydb869 ydb872 ydb864 ydb888 ydb901 ydb919"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r136 test DONE."
