#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#################################################
# C9D03-002250 Support Long Names
# Test all the M commands to work with long names
#################################################
echo "M commands test starts ..."
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv subtest_list "routine view readwt misc mlabelsnumber"
if ($?gtm_chset) then
	if ("UTF-8" == "$gtm_chset") then
		set utf8mode
	endif
endif
if ($?utf8mode) then
	setenv subtest_list "$subtest_list uzbreak"
else
	setenv subtest_list "$subtest_list zbreak"
endif

unset utf8mode
$gtm_tst/com/submit_subtest.csh
echo "M commands test Done."
