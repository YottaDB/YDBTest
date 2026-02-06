#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
########################################
# v44002 tests contain tests for $ZTEXIT ISV [C9D03-002246] and miscellaneous TR fixes
########################################

echo 'v44002 tests START....'

setenv subtest_list_common ""
setenv subtest_list_common "$subtest_list_common errorint"
setenv subtest_list_common "$subtest_list_common manyints"
setenv subtest_list_common "$subtest_list_common multintr"
setenv subtest_list_common "$subtest_list_common nesttp"
setenv subtest_list_common "$subtest_list_common nointrpt"
setenv subtest_list_common "$subtest_list_common refniosv"
setenv subtest_list_common "$subtest_list_common smpltp"
setenv subtest_list_common "$subtest_list_common snglintp"
setenv subtest_list_common "$subtest_list_common tpwint"
setenv subtest_list_common "$subtest_list_common D9D04002314"
setenv subtest_list_non_replic ""
setenv subtest_list_replic ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# disable implicit mprof testing to avoid interference with explicit MPROF testing
unsetenv gtm_trace_gbl_name

# define env var that contains SIGUSR1 value on all platforms (needed by the $ZTEXIT subtests)
if ($HOSTOS == "OSF1") then
	setenv sigusrval 30
else if (($HOSTOS == "SunOS") || ($HOSTOS == "HP-UX") || ($HOSTOS == "OS/390")) then
	setenv sigusrval 16
else if ($HOSTOS == "Linux") then
	setenv sigusrval 10
endif

$gtm_tst/com/submit_subtest.csh
echo 'v44002 tests DONE....'
