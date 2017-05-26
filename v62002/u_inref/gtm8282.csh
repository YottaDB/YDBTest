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

# Verify that the time passed in the interrupt handler counts towards the lock timeout
$gtm_tst/com/dbcreate.csh mumps 1

$gtm_exe/mumps -run lockintr

# The last line should have a TEST-I-PASS message
$tail -n 1 lockintr.mjo

$gtm_tst/com/dbcheck.csh
