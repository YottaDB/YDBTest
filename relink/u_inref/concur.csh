#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a test of concurrent relinkctl file and shared memory updates. It invokes an M program that
# fires off concurrent processes that create object files of roughly the specified size and execute them,
# thus causing updates to relinkctl file and shared memory entries.

mkdir src obj

# Having encryption enabled slows down this test too much, so turn it off.
setenv test_encryption NON_ENCRYPT

$gtm_tst/com/dbcreate.csh mumps

set rand_option = `$gtm_dist/mumps -run %XCMD 'write $random(2)'`

# Depending on the random option chosen, either have 10 processes on huge object files or 200 processes
# operating on smaller object files.
if ($rand_option) then
	touch 10_processes
	$gtm_dist/mumps -run concur 10 0 18 > mumps.out
else
	touch 200_processes
	$gtm_dist/mumps -run concur 200 0 16 > mumps.out
endif

$gtm_tst/com/dbcheck.csh
