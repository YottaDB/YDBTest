#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set test=gtm8404
set m_test_file_path = "$gtm_tst/$tst/inref"

echo "TEST $test : "

set verbose_name = $m_test_file_path/${test}verbose
set terse_name = $m_test_file_path/${test}terse
set temp_verbose_name = tmp_verbose_${test}.lis
set temp_terse_name = tmp_terse_${test}.lis

# Compile the specified files
$gtm_exe/mumps -list -machine $verbose_name.m
#Prepare files for comparison
sed -n '/^ \{10\}[0-9]/p' ${test}verbose.lis > $temp_verbose_name

$gtm_exe/mumps -list -machine $terse_name.m
sed -n '/^ \{10\}[0-9]/p' ${test}terse.lis > $temp_terse_name

# Do the comparison
# For now, simply make sure the # of instructions is the same

# Also compare the number of instructions
## If UTF-8 is set, skip this step, as we don't optimize $TEXT in these conditions
echo -n "Comparing number of instruction: "
set verbose_instructions = `wc -l $temp_verbose_name | cut -d\  -f 1`
set terse_instructions = `wc -l $temp_terse_name | cut -d\  -f 1`
if ($verbose_instructions == $terse_instructions) then
	echo "PASS"
else
	echo "FAIL (${test}verbose.lis=$verbose_instructions != ${test}terse.lis=$terse_instructions)"
endif

# Also try running the two, and expect the output to work
echo "Running $gtm_exe/mumps -run ${test}verbose"
set verbose_output = `$gtm_exe/mumps -run ${test}verbose`
echo "Running $gtm_exe/mumps -run ${test}terse"
set terse_output = `$gtm_exe/mumps -run ${test}terse`

echo -n "Comparing outputs: "
if ("$verbose_output" == "$terse_output") then
	echo "PASS"
else
	echo "FAIL"
endif
echo "Expected: $terse_output"
echo "Actual:   $verbose_output"
