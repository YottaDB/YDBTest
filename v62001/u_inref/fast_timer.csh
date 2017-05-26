#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test to verify correct sleep durations for a HANG command. The key facts are that a) we no longer unconditionally add
# 10ms to any timer; therefore, sub-10ms sleeps are possible on most platforms; and b) sub-10ms sleeps are implemented
# using nanosleep()s, which are resumed immediately in case of an outofband rather then scheduled for later by placing
# a special structure on the M stack.
#
# This script specifically chooses the number and maximum permissible duration of 1ms and 10ms HANGs per loop (10 loops
# of each kind are scheduled) before invoking the M program to validate the numbers. The reason for different numbers
# on certain boxes is that they have a poor (10ms) timer accuracy, amplified by many repetitions.

set hostn = $HOST:r:r:r

if ($hostn =~ {atlhxit1,atlst2000,charybdis}) then
	@ count_of_1ms = 30
	@ count_of_10ms = 30
	@ pass_for_1ms = 1500
	@ pass_for_10ms = 1500
else if (("HOST_LINUX_IX86" == $gtm_test_os_machtype) || ($hostn =~ bahirs)) then
	@ count_of_1ms = 100
	@ count_of_10ms = 30
	@ pass_for_1ms = 700
	@ pass_for_10ms = 1500
else
	@ count_of_1ms = 100
	@ count_of_10ms = 30
	@ pass_for_1ms = 500
	@ pass_for_10ms = 1500
endif

$gtm_dist/mumps -run fasttimer $count_of_1ms $count_of_10ms $pass_for_1ms $pass_for_10ms

if (! $status) then
	echo "TEST-I-PASS, Test succeeded."
endif
