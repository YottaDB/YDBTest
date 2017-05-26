#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Create routine with routine name other than what it is to form ZLMODULE error. This fix (GTM-8068)
# changes the failure from an assertpro to ZLMODULE.
#
$gtm_dist/mumps $gtm_tst/$tst/inref/gtm8068.m
mv gtm8068.o gtm8068a.o
$gtm_dist/mumps -nameofrtn=GTM8068 $gtm_tst/$tst/inref/gtm8068.m
echo "Expect ZLINKFILE/ZLMODULE errors from these invocations"
$gtm_dist/mumps -run gtm8068
$gtm_dist/mumps -run gtm8068a
