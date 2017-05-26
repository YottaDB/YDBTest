#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_test_disable_randomdbtn 1
setenv gtm_test_mupip_set_version "DISABLE"
setenv gtm_test_freeze_on_error 0
$gtm_tst/com/dbcreate.csh mumps 2 255 512 1024 2048 1024
$gtm_exe/mumps -run gtm7160
$gtm_tst/com/dbcheck.csh
