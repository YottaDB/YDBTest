#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
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
GTM-DE201381 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637458)

MUPIP LOAD -FORMAT=BINARY checks the record length against the data for a record; starting with V6.0-000, GT.M defines record
length as the data in a node, but the utility in question still inappropriately included the key in its length check.
(GTM-DE201381)
CAT_EOF
echo ""
setenv ydb_prompt "GTM>"
setenv ydb_msgprefix "GTM"		# So can run the test under GTM
echo "# Create a database file with key size of 8 and record size of 3."
$gtm_tst/com/dbcreate.csh mumps -key=8 -rec=3
echo ""
echo '# Store ^a("abc")=123 into database'
echo ""
$GTM << 'END'
set ^a("abc")=123
zwrite ^a
'END'
echo ""
echo "# Extract database file with format=bin"
$MUPIP extract -format=bin tmp.bin
echo ""
echo "# MUPIP LOAD -FORMAT=BINARY should succeed. Previous versions crash with CORRUPTNODE error."
$MUPIP load -format=bin tmp.bin
echo ""
echo "# Validate database integrity"
$gtm_tst/com/dbcheck.csh
echo ""
echo '# Since the dbcreate.csh below will rename exising db and gld, move it away temporarily'
$gtm_tst/com/backup_dbjnl.csh bak "*.dat *.gld" mv nozip
echo ""
echo "# Create temporary database file with record size = 4."
$gtm_tst/com/dbcreate.csh mumps2 -key=8 -rec=4
setenv gtmgbldir "mumps2.gld"
echo ""
echo '# Store ^a("def")=1234 into temporary database'
$GTM << 'END'
set ^a("def")=1234
'END'
echo ""
echo "# Extract database file with format=bin"
$MUPIP extract -format=bin tmp2.bin
echo ""
echo "# Move mumps.* in backup path back to current working path"
mv bak/* .
echo ""
echo '# Change GLD to set database file to mumps.gld instead of mumps2.gld'
setenv gtmgbldir "mumps.gld"
echo ""
echo '# Verfiy that current database file have record size = 3.'
$DSE d -f |& $grep "Maximum record size" | $tst_awk '{print $4}'
echo ""
echo '# MUPIP LOAD -FORMAT=BINARY should fail with error REC2BIG.'
$MUPIP load -format=bin tmp2.bin
