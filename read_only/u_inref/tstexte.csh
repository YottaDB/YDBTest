#! /usr/local/bin/tcsh -f
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
# This module is derived from FIS GT.M.
#################################################################
#Tests of mupip command "EXTEND" on a read_only database file
echo ""
echo "*** TSTEXTE.CSH ****"
echo ""

# dbcreate.csh not called because we re-use the database created by tstcreate.csh
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "***** mumps.dat R/W  mumps.mjl R/W *****"
echo "mupip extend DEFAULT"
$MUPIP extend DEFAULT
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

/bin/rm -f mumps.dat mumps.mjl
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "***** mumps.dat R/W  mumps.mjl R/O *****"
echo "mupip extend DEFAULT "
$MUPIP extend DEFAULT
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

/bin/rm -f mumps.dat mumps.mjl
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "***** mumps.dat R/O  mumps.mjl R/W *****"
echo "mupip extend DEFAULT "
$MUPIP extend DEFAULT
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

/bin/rm -f mumps.dat mumps.mjl
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "***** mumps.dat R/O  mumps.mjl R/O *****"
echo "mupip extend DEFAULT "
$MUPIP extend DEFAULT
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

/bin/rm -f mumps.dat mumps.mjl
