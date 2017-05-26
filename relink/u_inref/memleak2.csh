#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test for memory leaks in recursive relink operations. We choose random numbers in the range of [1; 7] and use them as arguments to
# the memleak2 M program which then runs a recursive relink scenario with the specified depth, breadth, and number of modules to
# create (in that order). Values beyond 7 produce long-running tests on certain platforms.

# If not replaying, pick random settings.
if !($?gtm_test_replay) then
	setenv memleak_config `$gtm_tst/com/genrandnumbers.csh 3 1 7`
	echo "setenv memleak_config ($memleak_config)" >> settings.csh
endif

# Record the chosen settings.
echo "$memleak_config" >&! mumps.out
$gtm_dist/mumps -run memleak2 $memleak_config[1] $memleak_config[2] $memleak_config[3] >>&! mumps.out

# Check if the test succeeded.
$grep -q FAIL mumps.out
if (1 == $status) then
	echo "TEST-I-SUCCESS, Test succeeded."
endif
