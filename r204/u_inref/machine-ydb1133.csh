#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# ---------------------------------------------------'
echo '# Test that [mumps -machine] generates opcodes for an M file.'
echo '# Also test that -length is accepted and ignored.'
echo '# ---------------------------------------------------'

echo '# Test that we see opcodes for WRITE'
echo ' set x=1  write x' > sample.m
$gtm_dist/yottadb -machine sample.m
echo '# The exact contents of this file are not important. This just verifies that it looks vaguely like VAX bytecode.'
echo '# Filter the byte length out (it differs when passed -dynamic_literals)'
grep OC_WRITE sample.lis | sed -E 's/\s[0-9]+\s/N/'

echo '# Test that we do not crash on file names that are too long.'
$gtm_dist/yottadb -machine $gtm_tst/call_ins/inref/greaterThan31charfileshouldnotbecalled.m
echo '# The exact contents of this file are also not important. The point is to make sure we generate a listing and do not crash.'
grep -o 'OC_BINDPARM' greaterThan31charfileshouldnotb.lis | head -n1

echo '# Test that files with no .m extension generate the right file name'
echo ' set x=1  write x' > x
cp x xy
$gtm_dist/yottadb -machine x
if (! -f x.lis) then
	echo 'TEST-E-FAIL: missing file x.lis'
	ls *.lis
endif
$gtm_dist/yottadb -machine xy
if (! -f xy.lis) then
	echo 'TEST-E-FAIL: missing file xy.lis'
	ls *.lis
endif

echo '# Test that `-length` does not generate a list file'
rm sample.lis
$gtm_dist/yottadb -length=66 sample.m
if (-f sample.lis) then
	echo 'TEST-E-FAIL: -length should not cause a list file to be generated'
endif

echo '# Test that `-length` does not modify the contents of a list file'
$gtm_dist/yottadb -list                       sample.m
$gtm_dist/yottadb -list=length.lis -length=10 sample.m
diff sample.lis length.lis
echo '# Test that `-length=0` is accepted and ignored'
$gtm_dist/yottadb -list=length.lis -length=0  sample.m
diff sample.lis length.lis
echo '# Test that `-length` does not crash if smaller than the size of the listing file.'
$gtm_dist/yottadb -list=no-crash.lis -length=8 -machine sample.m
if (`wc -l < no-crash.lis` <= 8) then
	echo 'TEST-E-FAIL: wanted to test behavior on a file at least 8 lines long'
endif
