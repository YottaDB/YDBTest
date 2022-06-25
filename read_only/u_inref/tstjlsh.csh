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
echo ""
echo "*** TSTJLSH.CSH ***"
echo ""
echo "*** Test for MUPIP JOURNAL -SHOW ***"
setenv GTM "$gtm_exe/mumps -direct"

# dbcreate.csh not used because we re-use the database created by tstcreate.csh
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM << EOF
w "do init",!  d ^init
EOF

echo "*** Showing on R/W mumps.dat R/W mumps.mjl ***"
lsmumps
echo "mupip journal -show=all -forward mumps.mjl >& jlsh1.out"
$MUPIP journal -show=all -forward mumps.mjl >& jlsh1.out
ipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

echo "*** Showing on R/W mumps.dat R/O mumps.mjl ***"
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip journal -show=all -forward mumps.mjl >& jlsh2.out"
$MUPIP journal -show=all -forward mumps.mjl >& jlsh2.out
ipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

echo "*** Showing on R/O mumps.dat R/W mumps.mjl ***"
chmod 444 mumps.dat
chmod 666 mumps.dat
lsmumps
echo "mupip journal -show=all -forward mumps.mjl >& jlsh3.out"
$MUPIP journal -show=all -forward mumps.mjl >& jlsh3.out
ipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

echo "*** Showing on R/O mumps.dat R/O mumps.mjl ***"
chmod 444 mumps.mjl
chmod 444 mumps.dat
lsmumps
echo "mupip journal -show=all -forward mumps.mjl >& jlsh4.out"
$MUPIP journal -show=all -forward mumps.mjl >& jlsh4.out
ipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

$grep successful jlsh*.out
\rm -f mumps.dat mumps.mjl
