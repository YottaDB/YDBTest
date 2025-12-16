#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

echo '# Check that concatenating strings that already happen to be at the end of the stringpool'
echo '# produces very fast concatenation operations. We have seen the CPU instructions range'
echo '# from 15 million to 60 million with V70005 and go as high as 530 million with V70004.'
echo '# So we set the limit at 65,000,000 CPU instructions and treat anything less than that as a PASS.'

# stp_gcol() preserves order of string addresses in the stringpool thereby ensuring garbage collection will
# continue to keep strings at the end of the stringpool. But stp_gcol_nosort() will not preserve the order
# Therefore force stp_gcol() to always sort for this test (otherwise the test will fail because it takes longer to run).
setenv ydb_stp_gcol_nosort 0

# In UTF-8 mode, the instructions are noticeably more so we disable that to keep the test limits as strict as possible.
$switch_chset "M" >& switch_chset.log

set limit = 65000000

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
	if ( "$instructions[1]" > $limit ) echo "FAIL: Test took more than $limit instructions [($instructions[1] instructions]"`false` || continue
	echo "PASS: Took less than $limit instructions"
end
