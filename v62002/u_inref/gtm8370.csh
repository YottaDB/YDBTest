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
#
# GTM-8370 [nars] SIG-11 from ZSHOW after a MERGE/Trigger-invocation/Runtime-error/ZGOTO sequence
#

echo "Create database file mumps.dat"
$gtm_tst/com/dbcreate.csh mumps

echo "Load triggers"
$gtm_exe/mumps -run init^gtm8370

echo "Run gtm8370 test"
$gtm_exe/mumps -run gtm8370

echo "Do a dbcheck to ensure db integs clean"
$gtm_tst/com/dbcheck.csh
