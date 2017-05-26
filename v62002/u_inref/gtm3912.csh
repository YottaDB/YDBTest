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
# test that narrow terminal widths don't cause problems for ZSHOW "D" (GTM-3912) or ZWRITE (GTM-5756)
setenv TERM vt320
echo "# Running expect (output: expect.out)"
expect $gtm_tst/$tst/u_inref/gtm3912.exp > expect.out
$grep -c "NOPAST" expect.out
$grep -c "brown" expect.out
endif
