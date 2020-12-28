#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# yottadb direct mode suspends from SIGSTOP and resumes again without"
echo "# an assert"

# Turn on expect debugging using "-d". The debug output would be in expect.dbg
# in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/ydb612.exp > ydb612.exp.out) >& ydb612.exp.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif

perl $gtm_tst/com/expectsanitize.pl ydb612.exp.out > ydb612.exp.sanatized.out
cat ydb612.exp.sanatized.out
