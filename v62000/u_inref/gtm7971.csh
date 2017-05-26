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
#
# GTM-7971 - prevent indefinite loop from an extrinsic within a boolean when it returns a FALSE
#
#if the test fails with an indefinite loop the child process runs wild and must be killed by hand
unsetenv save_side
if ($?gtm_side_effects) then
  setenv save_side $gtm_side_effects
  unsetenv gtm_side_effects
endif
if ($?gtm_boolean) then
  setenv save_boolean $gtm_boolean
endif
cp $gtm_tst/$tst/inref/gtm7971.m .
setenv gtm_boolean 0
$gtm_dist/mumps gtm7971.m
$gtm_dist/mumps -run gtm7971
setenv gtm_boolean 1
$gtm_dist/mumps gtm7971.m
$gtm_dist/mumps -run gtm7971
if ($?save_boolean) then
  setenv gtm_boolean $save_boolean
  unsetenv save_boolean
else
  unset gtm_boolean
endif
if ($?save_side) then
  setenv gtm_side_effects $save_side
  unsetenv save_side
endif
