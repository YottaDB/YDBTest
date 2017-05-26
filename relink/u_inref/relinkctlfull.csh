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

# Test for memory and file descriptor leaks on RELINKCTLFULL error. We rely on a white-box setting to limit the number of
# autorelinkable routines per object directory to 100. Once that limit is reached, we continue our attempts to link a new routine
# for another 2,000 times, encountering a RELINKCTLFULL error each time. This should not cause memory and file descriptor leaks.

# This white-box test sets the maximum number of relinkctl entries at 100.
setenv gtm_white_box_test_case_number 117
setenv gtm_white_box_test_case_enable 1

# Invoke the helper routine to link routines up to and beyond our relinkctl quota.
$gtm_dist/mumps -run relinkctlfull >&! mumps.out

# See if we succeeded.
$grep -qE "(ZLINK|FAIL)" mumps.out
if (1 == $status) then
	echo "TEST-I-SUCCESS, Test succeeded."
endif

# Unset the white-box test.
setenv gtm_white_box_test_case_enable 0
