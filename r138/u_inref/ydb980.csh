#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "# Fix various bugs in %YDBJNLF"
echo "# 1. Allow extract if db file is not available (previously failed with %YDB-W-DBCOLLREQ)"
echo "# 2. Long records are ingested correctly (previously failed with an LVUNDEF error)"
echo "# 3. Transaction records are ingested correctly (previously failed with %YDBJNLF-F-BADRECTYPE)"
echo ""
echo "# Creating unjournaled database"
setenv gtm_test_jnl "NON_SETJNL"	# Disable random journaling
$gtm_tst/com/dbcreate.csh mumps         # Create one region database

echo ""
echo "# Adding ability to add long data"
$MUPIP set -record_size=1000000 -region DEFAULT
$MUPIP set -global_buffer=65536 -region DEFAULT

echo ""
echo "# Turning on journaling"
$MUPIP set -journal="enable,on,nobefore,f=myjournal.mjl" -region DEFAULT

echo ""
echo "# Set long globals (999999 bytes) in a transaction + triggers"
$gtm_exe/mumps -run setx^ydb980

echo ""
echo "# Delete database file"
rm mumps.dat

echo ""
echo "# Create a brand new database unrelated to first database"
echo "# (Still not journaled)"
$gtm_tst/com/dbcreate.csh foo
setenv ydb_gbldir "foo.gld"

echo ""
echo "# Ingest journal file"
echo "# (expect no errors)"
$gtm_exe/mumps -run %XCMD 'DO INGEST^%YDBJNLF("myjournal.mjl")'

echo "# Analyze journal data"
$gtm_exe/mumps -run dataSummary^ydb980
