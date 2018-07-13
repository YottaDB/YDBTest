#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#
(expect -d $gtm_tst/$tst/u_inref/gtm8711.exp > expect.outx) >& xpect.dbg
if ($status) then
	echo "EXPECT FAILED"
endif
echo "# TESTING CENABLE"
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
cat expect_sanitized.outx
