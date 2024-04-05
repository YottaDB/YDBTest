#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# This test is to test output of ZSHOW "D" for TTSYNC, HOSTSYNC and CONVERT'
echo ''
(expect -d $gtm_tst/$tst/u_inref/ydb1068.exp > expect.outx) >& expect.dbg
if ($status) then
	echo "TEST-E-FAIL Expect error"
else
  tr -d '\01' < expect.outx > expect_sanitized1.outx
	perl $gtm_tst/com/expectsanitize.pl expect_sanitized1.outx > expect_sanitized.outx
	cat expect_sanitized.outx
endif
