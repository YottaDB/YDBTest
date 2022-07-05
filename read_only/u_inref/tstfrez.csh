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
#Tests of mupip command "FREEZE" on a read_only database file
echo ""
echo "*** TSTFREZ.CSH ***"
echo ""

# dbcreate.csh not called because we re-use the database created in tstcreate.csh
echo "***** mumps.dat R/W  mumps.mjl R/W *****"
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "mupip freeze -on DEFAULT"
$MUPIP freeze -on DEFAULT >& freeze_on_DEFAULT.out
ipcmanage

echo "mupip freeze -off DEFAULT"
$MUPIP freeze -off DEFAULT >& freeze_off_DEFAULT.out
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

/bin/rm -f mumps.dat mumps.mjl
echo "***** mumps.dat R/W  mumps.mjl R/O *****"
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip freeze -on DEFAULT"
$MUPIP freeze -on DEFAULT >& freeze1_on_DEFAULT.out
ipcmanage
echo "mupip freeze -off DEFAULT"
$MUPIP freeze -off DEFAULT >& freeze1_off_DEFAULT.out
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

/bin/rm -f mumps.dat mumps.mjl
echo "***** mumps.dat R/O  mumps.mjl R/W *****"
\cp -f  tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "mupip freeze -on DEFAULT"
$MUPIP freeze -on DEFAULT
ipcmanage
echo "mupip freeze -off DEFAULT"
$MUPIP freeze -off DEFAULT
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

/bin/rm -f mumps.dat mumps.mjl
echo "***** mumps.dat R/O  mumps.mjl R/O *****"
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip freeze -on DEFAULT"
$MUPIP freeze -on DEFAULT
ipcmanage
echo "mupip freeze -off DEFAULT"
$MUPIP freeze -off DEFAULT
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

/bin/rm -f mumps.dat mumps.mjl
