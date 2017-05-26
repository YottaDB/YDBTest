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
# Verify VIEW "POOLIMIT" and $VIEW("POOLLIMIT")
cp $gtm_tst/$tst/inref/gtm8191.gde ./		# copy the gde command file to the test directory for ease of debugging
setenv test_specific_gde gtm8191.gde		# so spanning region testing can create an appropriate mapping
setenv gtm_test_jnl NON_SETJNL		# because the MM region can't do BEFORE_IMAGE journaling which we randomly enable
setenv gtm_test_mupip_set_version "disable"	# because the MM region can do a dynamic block format change
setenv test_encryption NON_ENCRYPT		# even setting MMSEG to NOENCRYPTION doesn't keep encryption testing out of trouble
$gtm_tst/com/dbcreate.csh mumps 3 -allocation=2048 -extension_count=2048
setenv gtm_poollimit 10%
$gtm_dist/mumps -run gtm8191
$gtm_dist/mumps -run gtm8191a
$gtm_tst/com/dbcheck.csh
