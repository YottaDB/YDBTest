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

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE500860 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-DE500860)

The GT.M compiler accepts source files with arbitrary extensions. FIS recommends using the .m extension for source files as our testing of that is very extensive, however there may be cases where other extensions serve a purpose. Previously, the compiler enforced an explicit or implicit .m extension for source files. (GTM-DE500860)
CAT_EOF
echo ''

setenv ydb_msgprefix "GTM"
echo "# Test 1: Compile a routine with non-'.m' extension then run"
echo "# Create a test routine, 'testrtn.test', with a file extension of '.test'"
echo 'testRTN write "TEST",! quit' >& testrtn.test
echo "# Compile 'testrtn.test'"
$gtm_dist/mumps testrtn.test
echo "# Run [mumps -run testrtn]"
echo "# Confirm the test routine compiled and issued the correct output: 'TEST'"
echo "# Previously, when attempting to compile a routine without a '.m' extension,"
echo "# GT.M would issue a %GTM-E-FILENOTFND error."
$gtm_dist/mumps -r testrtn
echo "# Run [file testrtn.o] to confirm an object file was generated"
file testrtn.o
echo
echo "# Test 2: Run a routine with non-'.m' directly"
echo "# Create a test routine, 'testrtn2.test', with a file extension of '.test'"
echo 'testRTN write "TEST",! quit' >& testrtn2.test
echo "# Run 'testrtn2.test', expect ZLINKFILE and FILENOTFND errors"
$gtm_dist/mumps -r testrtn2
echo
echo "# Test 3: Compile a routine with non-'.m' extension using ZCOMPILE then run"
rm testrtn.o
echo "# Compile 'testrtn.test' with ZCOMPILE"
$gtm_dist/mumps -r %XCMD 'ZCOMPILE "testrtn.test"'
echo "# Run [mumps -run testrtn]"
echo "# Confirm the test routine compiled and issued the correct output: 'TEST'"
echo "# Previously, when attempting to compile a routine without a '.m' extension,"
echo "# GT.M would issue a %GTM-E-FILENOTFND error."
$gtm_dist/mumps -r testrtn
echo "# Run [file testrtn.o] to confirm an object file was generated"
file testrtn.o
