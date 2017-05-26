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

echo "gtm8290 subtest starts"
cp $gtm_tst/$tst/inref/gtm8290*.m .
$gtm_exe/mumps -run gtm8290
echo "gtm8290 subtest ends"
