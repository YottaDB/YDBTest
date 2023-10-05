#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test an incorrect assert that used to exist in mdb_condition_handler() related to jobinterrupt"
echo "# This tests https://gitlab.com/YottaDB/DB/YDB/-/issues/1029#note_1591890702"
echo "# Before YDB@1ed8a20d, this test used to previously fail an assert in mdb_condition_handler.c for expression"
echo '#   (\\!dollar_zininterrupt || ((int)ERR_ZINTRECURSEIO == SIGNAL) || ((int)ERR_STACKCRIT == SIGNAL))'
echo "# This test requires direct mode to fail hence the use of the [expect] utility below"

set file = "ydb1029"

(expect -d $gtm_tst/$tst/u_inref/$file.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx	# move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
cat expect_sanitized.outx

