#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################


echo '# Check that concatenating strings that already happen to be at the end of the stringpool'
echo '# produces very fast concatenation operations. For v70005 we expect CPU instructions under 150,000,000.'
echo '# (Max instructions used by v70005 is 69,020,710 on armv6l dbg; min is 14,714,225 on x86_64 pro.)'
echo '# (max instructions used by v70004 is 2,735,479,421 on armv6l dbg; min is 529,709,305 on x86_64 pro.)'

set limit = 150000000

# first run noop just to precompile the .o file
$gtm_exe/mumps -run noop^strcatEfficiency

set testmsg = ( \
	"# Test1: fast concatenating of strings that already exist at the end of stringpool" \
	"# Test2: fast concatenating of existing stringpool strings plus an appended string" \
)

foreach test ( 1 2 )
	echo
	echo "$testmsg[$test]"
	set instructions = `perf stat --log-fd 1 "-x " -e instructions $gtm_exe/mumps -run test$test^strcatEfficiency`
	echo "CPU instructions=$instructions[1]"
	if ( "$instructions[1]" == "" ) echo "No instruction count produced by perf: $instructions"`false` || continue
	if ( "$instructions[1]" > $limit ) echo "FAIL: Test took more than $limit instructions"`false` || continue
	echo "PASS: Took less than $limit instructions"
end
