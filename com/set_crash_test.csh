#!/usr/local/bin/tcsh -f
#################################################################
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

# Caller indicates to this script that it is a test that does crashes (kill -9). Set the related test system env var.
setenv gtm_test_crash 1

# A kill -9 could fail various "assert()" usages (which are valid only in a Debug build of YottaDB) as they assume
# a non-crash scenario as the normal case. Such asserts exist in wcs_flu.c, wcs_verify.c etc.
# Make those asserts aware that this test is a crash test by setting related white-box env vars.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29	# WBTEST_CRASH_SHUTDOWN_EXPECTED in YDB/sr_port/wbox_test_init.h

