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

# Setup white box test cases to get a fake big time.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 68
setenv gtm_white_box_test_case_count 1

$gtm_dist/mumps -run gtm8450

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_count
