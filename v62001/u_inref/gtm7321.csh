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
echo "Run with gtmcompile set to -nowarning so error is after the hello"
setenv gtmcompile "-nowarning"
$gtm_dist/mumps -run gtm7321
echo "Run with gtmcompile undefined so error is before the hello"
unsetenv gtmcompile
$gtm_dist/mumps -run gtm7321
cp $gtm_tst/$tst/inref/gtm7321*.m ./
echo "-nowarning should prevent messages to stderror but leave them in a listing"
$gtm_dist/mumps -list -nowarning gtm7321a.m
if (1 != `$grep -c INVCMD gtm7321a.lis`) echo "TEST-E-FAIL Exactly 1 INVCMD expected. Check gtm7321a.lis"
