#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# -------------------------------------------------------------------------------------------------------------'
echo '# Test M commands to serialize/deserialize local or global variable subtree'
echo '# -------------------------------------------------------------------------------------------------------------'
echo

setenv gtm_test_jnl NON_SETJNL
setenv ydb_stp_gcol_nosort 0
# Disable gtmdbglvl to prevent substantial slowdows.
# This is okay since ASAN will test memory issues without the need to use the internal memory manager.
if ($?gtm_test_libyottadb_asan_enabled) then
	if ($gtm_test_libyottadb_asan_enabled == 0) then
		setenv gtmdbglvl 0
	endif
endif
# Set ydb_readline to prevent byte sequences in expect output below that occur when ydb_readline is unset
setenv ydb_readline 1
$gtm_tst/com/dbcreate.csh mumps -key_size=256 -record_size=1048576 -null_subscripts=TRUE >& dbcreate.out

echo "### Test 0: Test ZYENCODE and ZYDECODE compilation errors "
echo "## T0a: Compile [ydb1152.m] routine"
echo "# Expect a series of compilation errors."
$ydb_dist/yottadb $gtm_tst/$tst/inref/ydb1152.m
echo
$ydb_dist/yottadb -r T0b^ydb1152
echo

# Tests 1-11
$ydb_dist/yottadb -run ydb1152

echo "### Test 12: CTRL-C during long-running ZYENCODE does not cause GTMASSERT2 failure on subsequent command"
set test_num = T12
(expect -d $gtm_tst/$tst/u_inref/mcomm_deserialize-ydb1152-${test_num}.exp $ydb_dist > ${test_num}expect.out) >& ${test_num}expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
else
	echo "PASS: Long-running ZYENCODE completed without GTMASSERT2 failure"
endif
mv ${test_num}expect.out ${test_num}expect.outx	# move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl ${test_num}expect.outx >& ${test_num}expect_sanitized.outx
echo

echo "### Test 13: Test that running ZYENCODE and ZYDECODE with 31 1MiB subscripts in a local variable does not cause a heap-buffer-overflow, or ZYDECODEINCOMPL or PARAMINVALID errors"
echo "### See also: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2843975764."
set tnum = T13
echo "# Run [${tnum}a^ydb1152] routine to pass 31 1MiB subscripts to ZYENCODE and ZYDECODE"
$ydb_dist/yottadb -run ${tnum}a^ydb1152 | $ydb_dist/yottadb -direct >& ${tnum}a.out
echo "# Confirm no PARAMINVALID and ZYDECODEINCOMPL errors were generated"
grep -E "PARAMINVALID|ZYDECODEINCOMPL" ${tnum}a.out
if (1 == $status) then
	echo "PASS: [${tnum}a^ydb1152] did not emit ZYDECODEINCOMPL and/or PARAMINVALID"
else
	echo "FAIL: [${tnum}a^ydb1152] emitted ZYDECODEINCOMPL and/or PARAMINVALID"
endif
echo "# Run [${tnum}b^ydb1152] routine to pass a single 1MiB subscript to ZYENCODE and ZYDECODE"
$ydb_dist/yottadb -run ${tnum}b^ydb1152 | $ydb_dist/yottadb -direct >& ${tnum}b.out
echo "# Confirm PARAMINVALID and ZYDECODEINCOMPL errors were generated"
$gtm_tst/com/check_error_exist.csh ${tnum}b.out PARAMINVALID ZYDECODEINCOMPL
echo

echo "### Test 14: Test that sending MUPIP INTRPT to ZYENCODE and ZYDECODE does not produce any of the following errors: ZYENCODEINCOMPL, ZYDECODEINCOMPL, TEST-E-FAIL"
echo "### See also:"
echo "###   1. https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2850600795"
echo "###   2. https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2851162582"
set test_num = T14
echo "# Run [$test_num^ydb1152] routine in the background"
($ydb_dist/yottadb -run ${test_num}a^ydb1152 & ; echo $! >! ${test_num}a.pid ) >& ${test_num}a.out
($ydb_dist/yottadb -run ${test_num}b^ydb1152 & ; echo $! >! ${test_num}b.pid ) >& ${test_num}b.out
set mpida = `cat ${test_num}a.pid`
set mpidb = `cat ${test_num}b.pid`
$gtm_tst/com/wait_for_proc_to_die.csh $mpida
$gtm_tst/com/wait_for_proc_to_die.csh $mpidb
echo "# Confirm no ZYENCODEINCOMPL, ZYDECODEINCOMPL, or TEST-E-FAIL errors were generated"
grep -E "ZYENCODEINCOMPL|ZYDECODEINCOMPL|FAIL" ${test_num}a.out
if (1 == $status) then
	echo "PASS: [$test_num^ydb1152] did not emit ZYDECODEINCOMPL and/or PARAMINVALID"
else
	echo "FAIL: [$test_num^ydb1152] emitted ZYDECODEINCOMPL and/or PARAMINVALID"
endif
echo

echo "### Test 15: No REC2BIG error is issued when values at default database record size"
echo "### are encoded and decoded when the database is created with default values."
echo "### See also: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2850600795."
echo "# Create a new database with default settings"
set test_num = T15
set initgld = $gtmgbldir
setenv gtmgbldir $test_num.gld
$gtm_dist/mumps -r GDE << GDE_EOF >& ${test_num}gde.out
change -segment DEFAULT -file=$test_num.dat
change -region DEFAULT -std
GDE_EOF
$ydb_dist/mupip create >& ${test_num}mupip.out
echo "# Run [$test_num^ydb1152] routine"
$ydb_dist/yottadb -run ${test_num}^ydb1152 >& ${test_num}.out
echo "# Confirm no REC2BIG errors were generated"
grep -E "REC2BIG|FAIL" ${test_num}.out
if (1 == $status) then
	echo "PASS: [$test_num^ydb1152] did not emit REC2BIG"
else
	echo "FAIL: [$test_num^ydb1152] emitted REC2BIG, or otherwise did not complete."
endif
echo

echo "### Test 16: No assert failure indirection is used to encode value at the default database record size"
echo "### For details: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2851331998"
echo "# Create a new database with default settings"
set test_num = T16
set initgld = $gtmgbldir
setenv gtmgbldir $test_num.gld
$gtm_dist/mumps -r GDE << GDE_EOF >& ${test_num}gde.out
change -segment DEFAULT -file=$test_num.dat
change -region DEFAULT -std
GDE_EOF
$ydb_dist/mupip create >& ${test_num}mupip.out
echo "# Run [$test_num^ydb1152] routine"
$ydb_dist/yottadb -run ${test_num}^ydb1152 | $ydb_dist/yottadb -dir >& ${test_num}.out
echo "# Confirm no assert failure occurred and a ZYENCODESRCUNDEF error was issued"
grep -E "ASSERT" ${test_num}.out
if (1 == $status) then
	echo "PASS: [$test_num^ydb1152] did not cause an assert failure"
else
	echo "FAIL: [$test_num^ydb1152] caused an assert failure."
endif
$gtm_tst/com/check_error_exist.csh ${test_num}.out ZYENCODESRCUNDEF
echo

echo "### Test 17: Test ZYENCODE within TSTART/TCOMMIT with restarts does not produce ZYDECODEINCOMPL or ZYENCODEINCOMPL errors"
echo "### See also: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2853870076"
set test_num = T17
setenv gtmgbldir mumps.gld
echo "# Run [$test_num^ydb1152] routine"
$ydb_dist/yottadb -run ${test_num}a^ydb1152 >& ${test_num}a.out
echo "# Confirm no ZYENCODEINCOMPL, ZYDECODEINCOMPL, or other errors were generated"
grep -E "ZYENCODEINCOMPL|ZYDECODEINCOMPL|-E-" ${test_num}.mjo*
if (1 == $status) then
	echo "PASS: [$test_num^ydb1152] did not emit any errors."
else
	echo "FAIL: [$test_num^ydb1152] emitted ZYDECODEINCOMPL, ZYENCODEINCOMPL, and/or another error"
endif
echo

echo "### Test 18: GVUNDEF for KILL during ZYENCODE loop shows global variable name"
set test_num = T18
(expect -d $gtm_tst/$tst/u_inref/mcomm_deserialize-ydb1152-${test_num}.exp $ydb_dist > ${test_num}expect.out) >& ${test_num}expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
else
	echo "PASS: GVUNDEF for KILL during ZYENCODE loop shows global variable name"
endif
mv ${test_num}expect.out ${test_num}expect.outx	# move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl ${test_num}expect.outx >& ${test_num}expect_sanitized.outx
echo

echo "### Test 19: ZYDECODE works with triggers (see test cases at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1767#note_2956960973)"
set test_num = T19
echo "# Run [$test_num^ydb1152] routine"
$ydb_dist/yottadb -run ${test_num}^ydb1152
echo

which jq >& /dev/null
if ($status == 1) then
	echo "ERROR: 'jq' utility not installed. Please install 'jq' before running this test."
else
	echo "# Check all ZYENCODE JSON output files for valid JSON"
	foreach file (`ls *.json`)
		jq . $file >& $file.jq.out
		if (0 == $status) then
			echo "PASS: $file contains valid JSON"
		else
			echo "FAIL: $file does not contain valid JSON"
		endif
	end
endif
echo

$gtm_tst/com/dbcheck.csh mumps >& dbcheck.out
