#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F134692 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-003_Release_Notes.html#GTM-F134692)

When MUPIP INTEG and MUPIP DUMPFHEAD arguments specify a region list, MUPIP processes regions in the listed order, or, for names
expanded by wildcard ("*"), alphabetically. Previously, MUPIP DUMPFHEAD and MUPIP INTEG ignored any user-specified order
of regions, and processed regions in FTOK order, which tends to change with changes in operational conditions within
the underlying file system. (GTM-F134692)

CAT_EOF

echo ""
echo "Test #1 : Test MUPIP INTEG"
echo ""
echo '# Creating a 5 region database DEFAULT, AREG, BREG, CREG, DREG'
$gtm_tst/com/dbcreate.csh mumps 5
echo ""
echo "# Run MUPIP FTOK to verify order of the databases"
$MUPIP ftok *.dat >& ftok.txt
echo ""
echo "# Run MUPIP Integ of database files in a specific order"
echo "# Expect BREG,AREG,CREG,DEFAULT,DREG"
$MUPIP integ -reg "BREG,AREG,CREG,DEFAULT,DREG" >& integ_1.out ; grep "Integ of region" integ_1.out
echo ""
echo "# Run MUPIP Integ of database files in a specific order where 2 regions are explicitly specified."
echo "# Expect BREG,AREG"
$MUPIP integ -reg "BREG,AREG" >& integ_2.out ; grep "Integ of region" integ_2.out
echo ""
echo "# Run MUPIP Integ of database files in a specific order where 3 regions are explicitly specified."
echo "# Expect CREG,AREG,BREG"
$MUPIP integ -reg "CREG,AREG,BREG" >& integ_3.out ; grep "Integ of region" integ_3.out
echo ""
echo '# Run MUPIP Integ of database files in a wildcard ("*REG")'
echo "# Expect AREG,BREG,CREG,DREG"
$MUPIP integ -reg "*REG" >& integ_4.out ; grep "Integ of region" integ_4.out
echo ""
echo '# Run MUPIP Integ of database files in a wildcard ("D*")'
echo "# Expect DEFAULT,DREG"
$MUPIP integ -reg "D*" >& integ_5.out ; grep "Integ of region" integ_5.out
echo ""
echo '# Run MUPIP Integ of database files in a wildcard ("*")'
echo "# Expect AREG,BREG,CREG,DEFAULT,DREG"
$MUPIP integ -reg "*" >& integ_6.out ; grep "Integ of region" integ_6.out
echo ""
echo "Test #2 : Test MUPIP DUMPFHEAD"
echo ""
echo "# Run MUPIP Dumpfhead of database files in a specific order"
echo "# Expect BREG,AREG,CREG,DEFAULT,DREG"
$MUPIP dumpfhead -reg "BREG,AREG,CREG,DEFAULT,DREG" >& dumpfhead_1.out ; grep "Fileheader dump of region" dumpfhead_1.out
echo ""
echo "# Run MUPIP Dumpfhead of database files in a specific order where 2 regions are explicitly specified."
echo "# Expect BREG,AREG"
$MUPIP dumpfhead -reg "BREG,AREG" >& dumpfhead_2.out ; grep "Fileheader dump of region" dumpfhead_2.out
echo ""
echo "# Run MUPIP Dumpfhead of database files in a specific order where 3 regions are explicitly specified."
echo "# Expect CREG,AREG,BREG"
# Region Name in Mixed cases should be accepted
$MUPIP dumpfhead -reg "Creg,areG,breg" >& dumpfhead_3.out ; grep "Fileheader dump of region" dumpfhead_3.out
echo ""
echo '# Run MUPIP Dumpfhead of database files in a wildcard ("*REG")'
echo "# Expect AREG,BREG,CREG,DREG"
$MUPIP dumpfhead -reg "*REG" >& dumpfhead_4.out ; grep "Fileheader dump of region" dumpfhead_4.out
echo ""
echo '# Run MUPIP Dumpfhead of database files in a wildcard ("D*")'
echo "# Expect DEFAULT,DREG"
$MUPIP dumpfhead -reg "D*" >& dumpfhead_5.out ; grep "Fileheader dump of region" dumpfhead_5.out
echo ""
echo '# Run MUPIP Dumpfhead of database files in a wildcard ("*")'
echo "# Expect AREG,BREG,CREG,DEFAULT,DREG"
$MUPIP dumpfhead -reg "*" >& dumpfhead_6.out ; grep "Fileheader dump of region" dumpfhead_6.out
