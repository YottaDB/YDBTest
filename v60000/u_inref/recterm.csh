#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Enable -defer_allocate so that we can get the GBLOFLOW error
setenv gtm_test_defer_allocate 1

$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out
$MUPIP set -region "*" -ext=0 >&! ext.out
$gtm_exe/mumps -run t1^recterm

$gtm_exe/dse change -file -writes_per_flush=100
$gtm_exe/mumps -run t2^recterm

$gtm_tst/com/dbcheck.csh
