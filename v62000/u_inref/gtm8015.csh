#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cp $gtm_tst/$tst/inref/gtm8015.m ./
setenv gtm_boolean -1
setenv gtm_side_effects -1
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean -1
setenv gtm_side_effects 0
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean -1
setenv gtm_side_effects 1
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean -1
setenv gtm_side_effects 2
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean -1
setenv gtm_side_effects 3
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 0
setenv gtm_side_effects -1
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 0
setenv gtm_side_effects 0
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 0
setenv gtm_side_effects 1
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 0
setenv gtm_side_effects 2
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 0
setenv gtm_side_effects 3
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 1
setenv gtm_side_effects -1
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 1
setenv gtm_side_effects 0
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 1
setenv gtm_side_effects 1
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 1
setenv gtm_side_effects 2
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 1
setenv gtm_side_effects 3
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 2
setenv gtm_side_effects -1
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 2
setenv gtm_side_effects 0
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 2
setenv gtm_side_effects 1
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 2
setenv gtm_side_effects 2
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 2
setenv gtm_side_effects 3
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 3
setenv gtm_side_effects -1
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 3
setenv gtm_side_effects 0
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 3
setenv gtm_side_effects 1
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 3
setenv gtm_side_effects 2
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
setenv gtm_boolean 3
setenv gtm_side_effects 3
$gtm_dist/mumps gtm8015.m
$gtm_dist/mumps -run gtm8015
