#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cp $gtm_tst/$tst/u_inref/gtm7658d.ro .

(expect -d $gtm_tst/$tst/u_inref/gtm7658.exp > expect.outx) >& expect.dbg
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx

$grep PASS expect_sanitized.outx		# just look for the pass to avoid dealing with things expect may insert on some platforms
