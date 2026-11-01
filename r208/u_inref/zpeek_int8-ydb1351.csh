#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1351] $ZPEEK() with the "I" or "U" format for an 8-byte field does not write past the end of    #'
echo '# the stringpool                                                                                     #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# $ZPEEK() with the "I" or "U" format reserved stringpool space for 10 digits, but an 8-byte field can'
echo '# have up to 20 digits. When less free space than the number of digits was left, the digits were'
echo '# written past the end of the stringpool, which failed an assert in a Debug build and wrote past the'
echo '# end of the allocated memory in a Release build. %PEEKBYNAME() uses $ZPEEK() so it had the same problem.'
echo '# Each stage peeks at node_local.nbb (19 digits when no backup is in progress) 100000 times, with the'
echo '# stringpool free space varied by a padding string, in a new process, and prints PASS or WRONG.'
echo

cp $gtm_tst/$tst/inref/ydb1351.m .
echo '# Create a database (the stages peek at its node_local structure)'
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
echo

# A nonzero storage debug level makes a Release build use the debug storage manager, whose block trailer absorbs
# a write of up to 10 bytes past the end of the stringpool so that an ASAN build does not report it.
echo '# Unset gtmdbglvl so that an ASAN Release build reports a write past the end of the stringpool'
unsetenv gtmdbglvl ydb_dbglvl
echo

foreach fmt (U I)
	switch ($fmt)
	case "U":
		echo '# Stage 1 : $$^%PEEKBYNAME("node_local.nbb","DEFAULT","U")'
		breaksw
	case "I":
		echo '# Stage 2 : $$^%PEEKBYNAME("node_local.nbb","DEFAULT","I")'
		breaksw
	endsw
	echo '#   expect the same 19-digit value from every call'
	echo '#   previously a Debug build failed an assert in gtm_memcpy_validate_and_execute.c, so the line below'
	echo '#   was an ASSERT error, and a Release build wrote past the end of the stringpool'
	echo '# Command : $gtm_dist/mumps -run fmt'"$fmt"'^ydb1351'
	$gtm_dist/mumps -run fmt${fmt}^ydb1351
	echo
end

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
