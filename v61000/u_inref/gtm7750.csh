#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# This test ensures that YottaDB does not zlink an M file only if the timestamp of the corresponding object file is at least a nanosecond older"

echo "# Create a simple M routine test.m"
cat >&! test.m <<EOF
test
	write "hello, world!",!
	quit
EOF

echo "# Compile the M routine."
$gtm_dist/mumps test.m

echo "# Compile the helper program stat.c"
cp $gtm_tst/$tst/inref/stat.c .
cc stat.c

echo "--------------------------------------------------------------"
echo "Test 1. Object is more than a second older than source (test.o, a)."
echo "--------------------------------------------------------------"
echo "# Make sure that a recompile happens if the source's and object's timestamps are more than a second apart."
./a.out 1 test.o test.m
./a.out 4 * |& sort >&! test-1-before.txt
cp -p test.o a
cp -p test.m a.m
$gtm_dist/mumps -run ^%XCMD 'do ^test'
./a.out 4 * |& sort >&! test-1-after.txt
ls -1t a test.o

echo "--------------------------------------------------------------"
echo "Test 2. Object is slightly older than source (test.o, b)."
echo "--------------------------------------------------------------"
echo "# Make sure that a recompile happens if the source's and object's timestamps are within the same second, but at least one nanosecond apart."
./a.out 2 test.o test.m
./a.out 4 * |& sort >&! test-2-before.txt
cp -p test.o b
cp -p test.m b.m
$gtm_dist/mumps -run ^%XCMD 'do ^test'
./a.out 4 * |& sort >&! test-2-after.txt
ls -1t b test.o

echo "--------------------------------------------------------------"
echo "Test 3. Object and source have the same timestamp (c, test.o)."
echo "--------------------------------------------------------------"
echo "# Make sure that a recompile happens even if the source's and object's timestamps match to the nanosecond."
./a.out 3 test.o test.m
./a.out 4 * |& sort >&! test-3-before.txt
cp -p test.o c
cp -p test.m c.m
$gtm_dist/mumps -run ^%XCMD 'do ^test'
./a.out 4 * |& sort >&! test-3-after.txt
ls -1t c test.o
