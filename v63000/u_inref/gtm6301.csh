#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# white box test for secshr_db_clnup handling of reads in progress
#
source $gtm_tst/com/gtm_test_setbgaccess.csh	# this is a BG-only test
#
$gtm_tst/com/dbcreate.csh .

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 120	# WBTEST_SIGTERM IN_T_QREAD

$gtm_dist/mumps -dir <<\EOF			# test for read
if $data(^a)
\EOF

$gtm_dist/mumps -dir <<\EOF			# test for new block
set ^a=1
\EOF

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number

# Quick double check of database coherency.
$gtm_tst/com/dbcheck.csh
