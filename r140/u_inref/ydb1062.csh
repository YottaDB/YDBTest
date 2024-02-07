#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv ydb_test_4g_db_blks 0	# Disable this random hugedb env var as it makes statsdb file integ output non-deterministic

echo "##############################################################################"
echo "# Test that MUPIP TRIGGER -STDIN reports correct line numbers"
echo "##############################################################################"

echo
echo "# -------------------------------------------------------------------"
echo "# test1 : Test that MUPIP TRIGGER -STDIN reports correct line numbers when input is not readily available"
echo "# -------------------------------------------------------------------"

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps

echo "# Trying the test case from https://gitlab.com/YottaDB/DB/YDB/-/issues/1062#note_1763076890"
echo "# Expect [Line 1] to be reported below"
echo "# Before the YDB#1062 fixes, one would see [Line 23845] or an arbitrary line number"
( sleep 1 ; echo "-*" ) | $gtm_dist/mupip trigger -stdin

echo
echo "# -------------------------------------------------------------------"
echo "# test2 : Test that MUPIP TRIGGER -STDIN reports correct line numbers when input has empty lines"
echo "# -------------------------------------------------------------------"
echo "# Specify non-empty lines in Line 1 and Line 3. And an empty line in Line 2"
echo "# Expect [Line 1] and [Line 3] to be displayed but not [Line 2]"
echo "# Before the YDB#1062 fixes too, the behavior would be the same and correct"
echo "# But during an interim version of the YDB#1062 fix that counted empty lines too,"
echo "# this test incorrectly displayed [Line 1] and [Line 2] and hence keeping this test."
echo "-*\n\n-*" | $gtm_dist/mupip trigger -stdin

echo
echo "# -------------------------------------------------------------------"
echo "# test3 : Test that MUPIP TRIGGER -STDIN does not use up CPU while waiting for data to be read from stdin"
echo "# -------------------------------------------------------------------"
echo "# This tests the need for a sleep while waiting for data to be read from stdin."
echo "# See https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1478#note_1765010891 for more details."
echo '# Run [ (sleep 3; echo "-*") | $gtm_dist/mupip trigger -stdin ]'
echo "# Expect the CPU usage percent for the above command to be less than 10% (PASS would be printed below in this case)"
echo "# When the sleep was not added in the code, this used to be close to 99% (indicating a spin-loop situation)."
echo "# Expect to see [PASS] below."
set timevar = `time $tst_tcsh -c '( sleep 3 ; echo "-*" ) | $ydb_dist/mupip trigger -stdin >& trig.out'`
echo $timevar > time.txt	# record in file for later debugging if needed in case of a test failure
set percent = `cat time.txt | $tst_awk '{print $4}' | sed 's/%//;'`
$gtm_dist/mumps -run %XCMD 'write "CPU usage less than 10% : ",$select('$percent'<10:"PASS",1:"FAIL"),!'
echo

$gtm_tst/com/dbcheck.csh

