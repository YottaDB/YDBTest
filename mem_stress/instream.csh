#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
if !( ($?test_replic) || ("GT.CM" == $test_gtm_gtcm) ) then
	echo "Run this test with -replic or -GTCM"
	exit 1
endif
setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`
echo "MEM_STRESS test starts..."
if (("1" == "$gtm_test_trigger") && ("GT.CM" == "$test_gtm_gtcm")) then
	echo "# Triggers not supported for GT.CM testing, unset gtm_test_trigger in instream" >>& settings.csh
	echo "setenv gtm_test_trigger 0" >>& settings.csh
	setenv gtm_test_trigger 0
endif

setenv subtest_list "memleak"

$gtm_tst/com/submit_subtest.csh
echo "MEM_STRESS test done."
