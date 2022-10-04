#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# test that timed read longer than the heartbeat timer (8 seconds) works appropriately
setenv TERM vt320
$gtm_tst/com/dbcreate.csh mumps 1
echo "# Running expect (output: expect.out)"
expect $gtm_tst/$tst/u_inref/gtm4911.exp > expect.out
$grep -c 'x=""' expect.out
endif
$gtm_tst/com/dbcheck.csh
