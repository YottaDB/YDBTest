#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`
echo "DUAL_FAIL_MULTISITE test Starts..."
setenv gtm_test_dbfill "IMPTP"
source $gtm_tst/com/set_crash_test.csh # sets YDBTest and YDB-white-box env vars to indicate this is a crash test
setenv test_sleep_sec 90
setenv test_sleep_sec_short 10
# use a tst_buffsize of 8MB for all dual fail tests, per C9D06-002314
setenv tst_buffsize 8388608
setenv subtest_list "dual_fail_multisite"
#
$gtm_tst/com/submit_subtest.csh
echo "DUAL_FAIL_MULTISITE test DONE."
