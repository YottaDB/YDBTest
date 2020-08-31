#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Starting from V6.3-009 MUPIP JOURNAL -EXTRACT supports -GVPATFILE qualifer. The new qualifier takes in"
echo "# a pattern file and searches the region for any variable that contains a value matching the pattern."

$gtm_tst/com/dbcreate.csh mumps

$MUPIP set -journal=enable,on,nobefore -reg "*" >& journal.txt

# Creating variables containing various patterns as values
$ydb_dist/mumps -r gtm8901

echo "~(*AA*)" >> pat1.txt
echo "*A*" >> pat1.txt
echo "# Using MUPIP JOURNAL EXTRACT with the GVPATFILE qualifer"
$ydb_dist/mupip journal -extract=ex.mjf -gvpatfile=pat1.txt -forward "*" >>& extract.log
echo "# Verify that all variables exept a(2) have been extracted"
$ydb_dist/mumps -run LOOP^%XCMD --xec=';write:$zfind(%l,"=") $zpiece(%l,"\",6)," ",$zpiece(%l,"\",11),!;' < ex.mjf

echo "A\**B" >> pat2.txt
echo "# Using MUPIP JOURNAL EXTRACT with the GVPATFILE qualifer"
$ydb_dist/mupip journal -extract=ex.mjf -gvpatfile=pat2.txt -forward "*" >>& extract.log
echo "# Verify that a(1) and a(4) have been extracted"
$ydb_dist/mumps -run LOOP^%XCMD --xec=';write:$zfind(%l,"=") $zpiece(%l,"\",6)," ",$zpiece(%l,"\",11),!;' < ex.mjf

echo "A%B%" >> pat3.txt
echo "# Using MUPIP JOURNAL EXTRACT with the GVPATFILE qualifer"
$ydb_dist/mupip journal -extract=ex.mjf -gvpatfile=pat3.txt -forward "*" >>& extract.log
echo "# Verify that only a(6) has been extracted"
$ydb_dist/mumps -run LOOP^%XCMD --xec=';write:$zfind(%l,"=") $zpiece(%l,"\",6)," ",$zpiece(%l,"\",11),!;' < ex.mjf

echo "# Verify that when no file is passed to -GVPATFILE produces a FILEOPENFAIL error"
$ydb_dist/mupip journal -extract=ex.mjf -gvpatfile=pat4.txt -forward "*"

$gtm_tst/com/dbcheck.csh

