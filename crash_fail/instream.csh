#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
#                                                               #
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "CRASH AND FAIL test Starts..."

source $gtm_tst/crash_fail/u_inref/subtest_settings.csh

setenv subtest_list "rcvr_failstopcrash_rs src_crash_fo"

$gtm_tst/com/submit_subtest.csh
echo "CRASH AND FAIL test DONE."
