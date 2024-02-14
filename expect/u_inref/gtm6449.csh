#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
#	All rights reserved.					#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that the delete key deletes the character on the cursor and it works when properly defined in the terminfo database
setenv tmpdir "test_term_dir"
setenv tmpfile "terminfo.txt"
setenv nodelfile "terminfo_nodel.txt"
setenv withdelfile "terminfo_withdel.txt"

set kcubval = "`infocmp vt220 | sed -n 's/.*kcub1=\([^,]*\).*/\1/p'`"
if ('\EOD' == $kcubval) then
    setenv alternate 1
else
    setenv alternate 0
endif

mkdir -p $tmpdir

echo "# Running expect (output: expect.out)"
(expect -d $gtm_tst/$tst/inref/gtm6449.exp > expect.out) >& expect.dbg
if ($status) then
    echo "TEST-E-FAIL Expect error check expect.out"
else
    echo "TEST-I-PASS"
endif
