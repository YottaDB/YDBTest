#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

echo '########################################################################################################'
echo '# Test that MUPIP DUMPFHEAD gives user friendly error messages in case input file is not a database file'
echo '########################################################################################################'

echo "# Create global directory file mumps.gld"
$GDE exit >& gde.out

echo ""
echo "# Run [mupip dumpfhead mumps.gld]"
echo "# This is to test YDB\!1291 and YDB\!1292"
echo "# Expect to see a %DUMPFHEAD-F-NOTADBFILE and %YDB-E-MUNOFINISH errors"
$MUPIP dumpfhead mumps.gld
set exit_status = $status
echo "# Also verify exit status is non-zero due to the above error"
echo "Exit status = $exit_status"

echo ""
set fname = "dumpfhead.out"
echo "# Run [mupip dumpfhead mumps.gld >& $fname]"
echo "# This is to test YDB\!1293 (i.e. redirecting stdout/stderr to file works too)"
echo "# Expect to see a %DUMPFHEAD-F-NOTADBFILE and %YDB-E-MUNOFINISH errors"
$MUPIP dumpfhead mumps.gld >& $fname
set exit_status = $status
cat $fname
rm $fname
echo "# Also verify exit status is non-zero due to the above error"
echo "Exit status = $exit_status"

