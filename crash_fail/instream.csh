#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
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

setenv subtest_exclude_list ""
if ($?ydb_environment_init) then
	# We are in a YDB environment (i.e. non-GG setup)
	# Disable below subtest until V63002 is available as this test hangs occasionally
	# (receiver server shutdown command waits for receiver server and update process to shut down)
	# due to issues which are believed to have been addressed in V63001A/V63002.
	setenv subtest_exclude_list "$subtest_exclude_list rcvr_failstopcrash_rs"
endif

$gtm_tst/com/submit_subtest.csh
echo "CRASH AND FAIL test DONE."
