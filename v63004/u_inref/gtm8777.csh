#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Testing QUIET and QCALL calls for the following utilities:"
echo "# %GCE	QUIET"
echo "# %GSE	QUIET"
echo "# %RCE	QUIET and QCALL"
echo "# %RSE 	QUIET and QCALL"
echo ""

echo "# Create a single region DB with region DEFAULT"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif
echo ""

echo "# Run setVars^gtm8777.m to populate DB with variables"
$ydb_dist/mumps -run setVars^gtm8777
echo ""

echo "# Output string to test1.m for later tests to ^%RCE and ^%RSE"
echo " This si a test string " > test1.m
echo ""
echo "# Output string to test2.m for later tests to ^%RCE and ^%RSE"
echo " " > test2.m
echo "Hello; I.T. Have you tried turning it off and on again? "

echo "# Run showVars^gtm8777.m to show variable values before running QUIET^%GCE"
$ydb_dist/mumps -run showVars^gtm8777
echo ""

echo "# Run gtm8777.exp to: "
echo "#		QUIET^%GCE - change all instances of 'a' to 'b' within variable ^a	"
echo "#		QUIET^%GSE - search all variables for the string 'Light'          	"
echo "#		QUIET^%RCE - change all instances of 'si' to 'is' within test1.m  	"
echo "#		QCALL^%RCE - append a success message to the end of test1.m       	"
echo "#		QUITE^%RSE - search all routines for every instance of 'is'       	"
echo "#		QCALL^%RSE - wearch all routines for every instance of 'this'     	"
## Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/gtm8777.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx	# move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
# The output is variable on slow vs fast systems and so filter out just the essential part of it to keep it deterministic.
echo ""
echo ""

echo "# Output from QUIET^%GCE "
echo "--------------------------------------------------------------"
awk '/---- QUIET\^%GCE ----/,/--------------/' expect_sanitized.outx | $grep -v '^$'
echo ""
echo ""

echo "# Output from QUIET^%GSE "
echo "--------------------------------------------------------------"
awk '/---- QUIET\^%GSE ----/,/--------------/' expect_sanitized.outx | $grep -v '^$'
echo ""
echo ""

echo "# Output from QUIET^%RCE "
echo "--------------------------------------------------------------"
# grep -v is used to remove any lines containing file paths, which are variable
awk '/---- QUIET\^%RCE ----/,/--------------/' expect_sanitized.outx | $grep -v "^/" | $grep -v '^$'
echo ""
echo ""

echo "# Output from QCALL^%RCE "
echo "--------------------------------------------------------------"
# grep -v is used to remove any lines containing file paths, which are variable
awk '/---- QCALL\^%RCE ----/,/--------------/' expect_sanitized.outx | $grep -v "^/" | $grep -v '^$'
echo ""
echo ""

echo "# Output from QUIET^%RSE "
echo "--------------------------------------------------------------"
# grep -v is used to remove any lines containing file paths, which are variable
awk '/---- QUIET\^%RSE ----/,/--------------/' expect_sanitized.outx | $grep -v "^/" | $grep -v '^$'
echo ""
echo ""

echo "# Output from QCALL^%RSE "
echo "--------------------------------------------------------------"
# grep -v is used to remove any lines containing file paths, which are variable
awk '/---- QCALL\^%RSE ----/,/--------------/' expect_sanitized.outx | $grep -v "^/" | $grep -v '^$'
echo ""
echo ""

$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
echo "# DB has shutdown gracefully"
