#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv TERM vt320
echo "# Running expect (output: expect.out)"
expect $gtm_tst/$tst/u_inref/gtm8454.exp > expect.out
$grep -c CTRL_C expect.out
$grep -c "PASS" expect.out
endif