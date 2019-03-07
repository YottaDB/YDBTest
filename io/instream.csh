#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# ------------------------------------------------------------------------------
# IO DEVICES TESTS
# ------------------------------------------------------------------------------
#
# manual_examples	[nergis]
# variable_stream	[nergis]
# errors		[nergis]
# exception		[nergis]
# deviceparam		[nergis]
# filetest		[nergis]
# x_y			[nergis]
# socket		[nergis]
# zeoftest		[nergis]
# C9H04002843		[Narayanan]
# pipetest		[Cronem]
# filezeof		[Cronem]
# pipeintrpt		[Cronem]
# fifointrpt		[Cronem]
# disk_follow		[Cronem]
# diskintrpt		[Cronem]
# diskfollow_timeout	[Cronem]
# closestatus		[Cronem]
# sdseek		[Cronem - GTM-7808]
# write_anywhere	[Cronem - GTM-8018]
# zshow_principal	[Cronem - GTM-8018]
# gtm7964		[Cronem]
# gtm8229		[sopini] Ensure that ioxx_write() / ioxx_wteol() calls do not nest.
# gtm8239		[sopini] Ensure the consistency of output between tt and rm devices and its correctness.
# gtm8369		[Cronem] Fix append issue for files greater than 4G
# gtm7060		[Cronem] Fix negative write issue of iorm_write.c in M mode
# ------------------------------------------------------------------------------
echo "I/O devices test starts..."
setenv subtest_list "manual_examples variable_stream errors exception deviceparam filetest x_y socket zeoftest "
setenv subtest_list "$subtest_list C9H04002843 pipetest filezeof pipeintrpt fifointrpt disk_follow diskintrpt "
setenv subtest_list "$subtest_list diskfollow_timeout closestatus sdseek write_anywhere zshow_principal gtm7964 "
setenv subtest_list "$subtest_list gtm8229 gtm8239 gtm8369 gtm7060"

setenv subtest_exclude_list    ""

if ($?ydb_test_exclude_diskfollow_timeout) then
	if ($ydb_test_exclude_diskfollow_timeout) then
		# An environment variable is defined to indicate the below subtest needs to be disabled on this host
		setenv subtest_exclude_list "$subtest_exclude_list diskfollow_timeout"
	endif
endif

$gtm_tst/com/submit_subtest.csh

echo "I/O devices test done..."
