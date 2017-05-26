#!/usr/local/bin/tcsh -f

#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# default to V5 database
setenv gtm_test_mupip_set_version "disable"

$gtm_tst/com/dbcreate.csh mumps 1

# Do a few updates that so the white box case gets a record count the white box case will inflate
$gtm_exe/mumps -run %XCMD 'for i=1:1:5 set ^x(i)=1'

# Setup white box test cases to get a fake big record count.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 68
setenv gtm_white_box_test_case_count 1

$MUPIP integ -region default
$MUPIP extract -fo=zwr gtm8128.zwr

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_count

$gtm_tst/com/dbcheck.csh
