#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#-------------------------------------------------------------------------------------
# Various tests of MUPIP JOURNAL -ROLLBACK -FORWARD (and a few other MUPIP JOURNAL commands)
#-------------------------------------------------------------------------------------
# verify     : Test of default verify behavior for various MUPIP JOURNAL commands; Test of REPLSTATEOFF/MUPJNLINTERRUPT messages
# misc_quals : Test of various things for MUPIP JOURNAL -ROLLBACK -FORWARD
#-------------------------------------------------------------------------------------

if (! $?test_replic) then
	echo "This test can only run with -replic. Exiting..."
	exit 1
endif

setenv subtest_list "verify misc_quals"
setenv subtest_exclude_list ""
# filter out subtests that cannot pass with MM
# "verify" subtest uses backward rollback which does not work with MM
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "verify"
endif

$gtm_tst/com/submit_subtest.csh
