#!/usr/local/bin/tcsh -f
#################################################################
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

echo "# Test update on database with READ_ONLY flag through multiple global directories"
echo ""

setenv gtm_test_db_format "NO_CHANGE"	# do not switch db format as that will cause incompatibilities with MM
					# which this test sets the access method to in the later stages.
# This test requires MM (READ_ONLY requires that access method).
# So force MM and therefore disable encryption & nobefore as they are incompatible with MM
setenv acc_meth MM
setenv test_encryption NON_ENCRYPT
source $gtm_tst/com/mm_nobefore.csh	# Force NOBEFORE image journaling with MM

echo "# Create gld mumps.gld mapping to the database file mumps.dat"
setenv ydb_gbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps	>& dbcreate_1.out

echo "# Create gld x.gld mapping to the same database file mumps.dat"
cp mumps.gld x.gld

echo "# Enable READ_ONLY flag on mumps.dat (need to also disable STATS flag on mumps.dat at the same time)"
$MUPIP set -read_only -nostats -acc=MM -reg "*"

$ydb_dist/mumps -run readonly

setenv ydb_gbldir mumps.gld
$gtm_tst/com/dbcheck.csh
