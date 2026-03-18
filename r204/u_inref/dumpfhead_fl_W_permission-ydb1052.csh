#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test that mupip dumpfhead -flush produces the correct error when db file does not have write permission."
$gtm_tst/com/dbcreate.csh mumps 2
echo
echo "# Test with two regions where AREG (a.dat) does not have OS write permissions"
chmod 444 a.dat
echo "# trying dumpfhead -flush on region AREG (no write permission)"
echo "# We expect a DBRDONLY error"
$gtm_dist/mupip dumpfhead -flush -region AREG > out1.txt
echo "# trying dumpfhead -flush on both regions, DEFAULT (writable) first then AREG (no write permission)"
echo "# We expect a DBRDONLY error for AREG"
$gtm_dist/mupip dumpfhead -flush -region DEFAULT,AREG > out2.txt
echo "# trying dumpfhead -flush on both regions, AREG first then DEFAULT"
echo "# We expect a DBRDONLY error for AREG"
$gtm_dist/mupip dumpfhead -flush -region AREG,DEFAULT > out3.txt
echo "# restore AREG permissions"
chmod 664 a.dat
echo

# You cannot set read_only on an encrypted database.
if ("NON_ENCRYPT" == $test_encryption) then
	echo "# trying with read_only database"
	echo "# First set to read_only"
	echo "# This will include a few other settings"
	echo "# necessary to set a database to read_only"
	$gtm_dist/mupip set -NOJOURNAL -reg DEFAULT
	$gtm_dist/mupip set -NOASYNCIO -NOSTATS -read_only -acc=MM -reg DEFAULT
	echo "# Then try dumpfhead -flush"
	echo "# We expect a DBRDONLY error"
	$gtm_dist/mupip dumpfhead -flush -region DEFAULT > out4.txt
	echo "# undo read_only"
	$gtm_dist/mupip set -noread_only -reg DEFAULT
else
	echo "# This is an encrypted database so skip the read_only test"
	echo "# as encrypted databases cannot be read_only."
endif
echo "# Running dbcheck.csh."
$gtm_tst/com/dbcheck.csh
