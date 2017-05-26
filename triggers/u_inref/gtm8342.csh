#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# Test to verify that MUPIP TRIGGER does not prompt for user input more than once
#

$gtm_tst/com/dbcreate.csh mumps 1 255 1024 4096 		>&! dbcreate1.log
# This is lame, but it reduces the reference file output
cp $gtm_tst/$tst/inref/gtm8342.trg ./
echo y | $gtm_dist/mupip trigger -triggerfile=gtm8342.trg	>&! triggerload.outx
$grep -v MUNOACTION triggerload.outx
$gtm_tst/com/dbcheck.csh					>&! dbcheck1.log

