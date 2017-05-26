#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-7552 : TPFAIL with failure code J
#
setenv gtm_test_spanreg 0		# The test assumes ^a* maps to AREG and ^b* maps to BREG
$gtm_tst/com/dbcreate.csh mumps 3	# see gtm7552.m for comments on why we need 3 regions
$gtm_exe/mumps -run gtm7552
$gtm_tst/com/dbcheck.csh
