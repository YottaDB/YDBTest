#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Disallow use of V6 mode DBs using a random V6 version as it changes the output from MUPIP INTEG and MUPIP SIZE
setenv gtm_test_use_V6_DBs 0
#
echo '# ----------------------------------------------------------------------------------------------'
echo '# Test that MUPIP SIZE -HEURISTIC="SCAN,LEVEL=1" gives accurate results (not a MUSIZEFAIL error)'
echo '# ----------------------------------------------------------------------------------------------'
echo '# Create database with smallest possible block size of 512 bytes (helps go more than 64Kib blocks with fewer data records)'
$gtm_tst/com/dbcreate.csh mumps -block_size=512
echo '# Load data ^x(1), ^x(2), ... up to ^x(200000) each with a value of 200 bytes'
$ydb_dist/yottadb -run dataload^ydb717
echo '# First run MUPIP INTEG -SUBSCRIPT with a key range of ^x(120000) to ^x(180000). Then filter out the Records information from it'
$MUPIP integ -reg DEFAULT -fast -full -subscript='"^x(120000)":"^x(180000)"' >& mupip_integ.out
$tst_awk 'BEGIN {globalseen = 0} $1 == "Global" {globalseen = 1; next} globalseen == 0 {next} $1 == "" {exit} {print $0}' mupip_integ.out
echo '# Then run MUPIP SIZE -SUBSCRIPT with the same key range of ^x(120000) to ^x(180000). Then filter out the Records information from it'
$MUPIP size -heuristic="scan,level=1" -subscript='"^x(120000)":"^x(180000)"' >& mupip_size.out
$tst_awk 'BEGIN {levelseen = 0} ($1 == "Level") { if (levelseen == 1) { next;} levelseen = 1;} $1 == "" {next} levelseen == 1 {print $0}' mupip_size.out
echo '# Verify both MUPIP SIZE -SUBSCRIPT and MUPIP INTEG -SUBSCRIPT have same Records in Level 1,2,3'
echo '# No need of explicit verification as the number of records is part of the reference file'
$gtm_tst/com/dbcheck.csh
