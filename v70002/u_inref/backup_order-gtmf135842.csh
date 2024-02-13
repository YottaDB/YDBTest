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
GTM-F135842 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637997)

When MUPIP BACKUP arguments specify a list, the utility processes regions in the listed order, or, for names expanded by wildcard
("*"), alphabetically. Previously, MUPIP BACKUP ignored any user-specified order of regions, and processed regions in FTOK order,
which tends to change with changes in operational conditions within the underlying file system.(GTM-F135842)
CAT_EOF
setenv ydb_msgprefix "GTM"
echo ""
echo '# Creating a 5 region database DEFAULT, AREG, BREG, CREG, DREG'
$gtm_tst/com/dbcreate.csh mumps 5
echo ""
echo "# Run MUPIP FTOK to verify order of the databases"
$MUPIP ftok *.dat >& ftok.txt
echo ""
echo "# Create backup path (bak)"
mkdir bak
echo ""
echo "# Run MUPIP Backup of database files in a specific orders"
echo "# Expect BREG,AREG,CREG,DEFAULT,DREG"
$MUPIP backup BREG,AREG,CREG,DEFAULT,DREG ./bak >& bck_tmpdir.out; $grep -Ev 'FILERENAME|JNLCREATE' bck_tmpdir.out
echo ""
echo "# Create backup path (bak2)"
mkdir bak2
echo ""
echo "# Run MUPIP Backup of database files in a specific orders with 2 regions are explicitly specified."
echo "# Expect BREG,AREG"
$MUPIP backup BREG,AREG ./bak2 >& bck2_tmpdir.out; $grep -Ev 'FILERENAME|JNLCREATE' bck2_tmpdir.out
echo ""
echo "# Create backup path (bak3)"
mkdir bak3
echo ""
echo "# Run MUPIP Backup of database files in a specific orders with 3 regions are explicitly specified."
echo "# Expect CREG,AREG,BREG"
$MUPIP backup CREG,AREG,BREG ./bak3 >& bck3_tmpdir.out; $grep -Ev 'FILERENAME|JNLCREATE' bck3_tmpdir.out
echo ""
echo "# Create backup path (bak4)"
mkdir bak4
echo ""
echo '# Run MUPIP Backup of database files in a wildcard ("*REG")'
echo "# Expect AREG,BREG,CREG,DREG"
$MUPIP backup '*REG' ./bak4  >& bck4_tmpdir.out; $grep -Ev 'FILERENAME|JNLCREATE' bck4_tmpdir.out
echo ""
echo "# Create backup path (bak5)"
mkdir bak5
echo ""
echo '# Run MUPIP Backup of database files in a wildcard ("D*")'
echo "# Expect DEFAULT,DREG"
$MUPIP backup 'D*' ./bak5  >& bck5_tmpdir.out; $grep -Ev 'FILERENAME|JNLCREATE' bck5_tmpdir.out
echo ""
echo "# Create backup path (bak6)"
mkdir bak6
echo ""
echo '# Run MUPIP Backup of database files in a wildcard ("*")'
echo "# Expect AREG,BREG,CREG,DEFAULT,DREG"
$MUPIP backup '*' ./bak6  >& bck6_tmpdir.out; $grep -Ev 'FILERENAME|JNLCREATE' bck6_tmpdir.out
