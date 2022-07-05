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
#Tests of mupip command "RESTORE" on a read_only database file
echo ""
echo "*** TSTRESTORE.CSH ***"
echo ""

# dbcreate.csh not used because we re-use the database created by tstcreate.csh
echo "*** Initializing....  and creating a normal (r+w) database ***"
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
setenv GTM "$gtm_exe/mumps -direct"
$GTM << EOF
w "do dbfill",!
d in0^dbfill("set")
EOF

$MUPIP backup -noonline -i DEFAULT bak.dat
$gtm_tst/com/dbcheck_filter.csh
\rm -f mumps.dat
$MUPIP create

echo "***** mumps.dat R/W mumps.mjl R/W *****"
lsmumps
echo "mupip restore mumps.dat bak.dat"
$MUPIP restore mumps.dat bak.dat
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

echo "***** mumps.dat R/W mumps.mjl R/O *****"
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip restore mumps.dat bak.dat"
$MUPIP restore mumps.dat bak.dat
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

echo "***** mumps.dat R/O mumps.mjl R/W *****"
\cp -f  tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "mupip restore mumps.dat bak.dat"
$MUPIP restore mumps.dat bak.dat
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

echo "***** mumps.dat R/O mumps.mjl R/O *****"
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip restore mumps.dat bak.dat"
$MUPIP restore mumps.dat bak.dat
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

\rm -f mumps.dat mumps.mjl bak.dat
