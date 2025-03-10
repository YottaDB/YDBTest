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
echo

setenv ydb_msgprefix "GTM"
echo "# Test 1: Compile a routine with non-'.m' extension then run"
echo "# Create a test routine, 'testrtn.test', with a file extension of '.test'"
echo 'testRTN write "PASS from testrtn",! quit' >& testrtn.test
echo "# Compile 'testrtn.test'"
$gtm_dist/mumps testrtn.test
echo "# Run [file testrtn.o] to confirm the test routine compiled and an object file was generated"
echo "# Previously, when attempting to compile a routine without a '.m' extension,"
echo "# GT.M would issue a %GTM-E-FILENOTFND error."
file testrtn.o
echo "# Run [mumps -run testrtn] and confirm it issues the correct output: 'PASS from testrtn'"
$gtm_dist/mumps -r testrtn
echo

echo "# Test 2: Run a routine with non-'.m' extension directly"
echo "# Create a test routine, 'testrtn2.test', with a file extension of '.test'"
echo 'testRTN write "FAIL from testrtn2",! quit' >& testrtn2.test
echo "# Run 'testrtn2.test', expect ZLINKFILE and FILENOTFND errors"
$gtm_dist/mumps -r testrtn2
echo

echo "# Test 3: Compile a routine with non-'.m' extension using ZCOMPILE then run"
rm testrtn.o
echo "# Compile 'testrtn.test' with ZCOMPILE"
$gtm_dist/mumps -r %XCMD 'ZCOMPILE "testrtn.test"'
echo "# Run [file testrtn.o] to confirm the test routine compiled and an object file was generated"
echo "# Previously, when attempting to compile a routine without a '.m' extension,"
echo "# GT.M would issue a %GTM-E-FILENOTFND error."
file testrtn.o
echo "# Run [mumps -run testrtn] and confirm it issues the correct output: 'PASS from testrtn'"
$gtm_dist/mumps -r testrtn
echo

echo "# Test 4: Compile a routine with no file extension then run"
echo '# This tests YDB\!1647 (https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1647)'
echo '# For more details see: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/660#note_2389125090'
echo "# Create a test routine, 'noextrtn' with no file extension"
echo 'noextRTN write "PASS from noextrtn",! quit' >& noextrtn
echo "# Compile 'noextrtn'"
$gtm_dist/mumps noextrtn
echo "# Run [file testrtn.o] to confirm the routine compiled and an object file was generated"
echo "# Previously, when attempting to compile a routine without a '.m' extension,"
echo "# GT.M would issue a %GTM-E-FILENOTFND error."
file noextrtn.o
echo "# Run [mumps -run noextrtn] to run the compiled routine and confirm it issues the correct output: 'PASS from noextrtn'"
$gtm_dist/mumps -r noextrtn
echo

echo "# Test 5: Run a routine no file extension directly"
echo "# Create a test routine, 'noextrtn2' with no file extension"
echo 'noextRTN write "FAIL from noextrtn2",! quit' >& noextrtn2
echo "# Run 'noextrtn2', expect ZLINKFILE and FILENOTFND errors"
$gtm_dist/mumps -r noextrtn2
