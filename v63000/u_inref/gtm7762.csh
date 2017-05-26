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

set TESTS = "t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19"
set M_TEST_FILE_PATH = '$gtm_tst/$tst/inref'

foreach test ($TESTS)
	echo "TEST $test : "

	set CONCAT_NAME = $M_TEST_FILE_PATH/${test}concat
	set TERSE_NAME = $M_TEST_FILE_PATH/${test}terse
	set TEMP_CONCAT_NAME = tmp_concat_${test}.lis
	set TEMP_TERSE_NAME = tmp_terse_${test}.lis

	if ($test == "t17") then
		# t17 wants to have side effects set
		setenv gtm_side_effects 2
	endif

	# Compile the specified files
	echo "Compiling ${CONCAT_NAME}.m..."
	$gtm_exe/mumps -list -machine $CONCAT_NAME.m
	#Prepare files for comparison
	sed -n '/^ \{10\}[0-9]/p' $test\concat.lis > $TEMP_CONCAT_NAME

	echo "Compiling ${TERSE_NAME}.m..."
	$gtm_exe/mumps -list -machine $TERSE_NAME.m
	sed -n '/^ \{10\}[0-9]/p' $test\terse.lis > $TEMP_TERSE_NAME

	# Do the comparison
	# For now, simply make sure the # of instructions is the same
	# We'll need to modify the hashtab to allow for the memory allocation to be the same; it'll be annoying.
	#set FILES_EQUAL = `cat $TEMP_CONCAT_NAME | grep -v -f $TEMP_TERSE_NAME | wc -l`

	#if ($FILES_EQUAL == 0) then
	#	echo -n "PASS"
	#else
	#	echo -n "FAIL"
	#endif

	# Also compare the number of instructions
	set CONCAT_INSTRUCTIONS = `$gtm_exe/mumps -run LOOP^%XCMD --after='@write %NR-1,\!' < $TEMP_CONCAT_NAME`
	set TERSE_INSTRUCTIONS =  `$gtm_exe/mumps -run LOOP^%XCMD --after='@write %NR-1,\!' < $TEMP_TERSE_NAME`
	echo -n "Comparing number of instruction: "
	if ($CONCAT_INSTRUCTIONS == $TERSE_INSTRUCTIONS) then
	        echo "PASS"
	else
	        echo "FAIL (${test}concat.lis=$CONCAT_INSTRUCTIONS != ${test}terse.lis=$TERSE_INSTRUCTIONS)"
	endif

	# Also try running the two, and expect the output to work
	echo "Running $gtm_exe/mumps -run ${test}concat"
	set CONCAT_OUTPUT = `$gtm_exe/mumps -run ${test}concat`
	echo "Running $gtm_exe/mumps -run ${test}terse"
	set TERSE_OUTPUT = `$gtm_exe/mumps -run ${test}terse`

	echo -n "Comparing outputs: "
	if ("$CONCAT_OUTPUT" == "$TERSE_OUTPUT") then
		echo "PASS"
	else
		echo "FAIL"
	endif
	echo -n "Expected: "
	echo "$TERSE_OUTPUT"
	echo -n "Actual: "
	echo "$CONCAT_OUTPUT"

	if ($test == "t17") then
		# t17 wants to have side effects set; reset them
		setenv gtm_side_effects 0
	endif
end

# This next test required unicode support
cat <<FIN > tmp.m
label
	FOR I=1:1:1024 DO
	. WRITE \$CHAR(9)_"set A=\$PIECE("""
	. DO ^%RANDSTR(I)
	. WRITE ""","""
	. DO ^%RANDSTR(\$RANDOM(I))
	. WRITE """,5)",!
FIN

if ("TRUE" == $gtm_test_unicode_support) then
	$switch_chset "UTF-8" >&! switch_utf8.out
	$gtm_exe/mumps -run crashtests

	# As an added bonus, try calling the $PIECE function a gazillion times
	# With different strings =D
	# This script takes a while to run; the purpose is to generate substrings, and generate mumps commands that consist of many
	#	combinations of those strings. We want to use the cache, but also require it roll over a few times
	echo -n 'SMOKE $PIECE: '
	$gtm_exe/mumps -run tmp  | $gtm_exe/mumps -direct > /dev/null

	if ($? == 0) then
		echo "PASS"
	else
		echo "FAIL"
	endif
endif
