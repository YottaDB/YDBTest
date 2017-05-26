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
# create a database
$gtm_tst/com/dbcreate.csh mumps

# Setup white box test cases to get a SIGTERM.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 121
setenv gtm_white_box_test_case_count 1

$gtm_dist/mumps -run \%XCMD "set ^a=1"

# tidy up white box environment
unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_count

# integ the database
$gtm_tst/com/dbcheck.csh
