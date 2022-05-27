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
echo "*** TSTJLVERI.CSH ***"
echo ""
echo "*** Test for MUPIP JOURNAL -VERIFY ***"
setenv GTM "$gtm_exe/mumps -direct"

# dbcreate.csh not used because we re-use the database created in tstcreate.csh
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM << EOF
w "do init",!  d ^init
EOF

echo "*** Verifying on R/W mumps.dat R/W mumps.mjl ***"
echo "mupip journal -verify -forward mumps.mjl"
$MUPIP journal -verify -forward mumps.mjl
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

echo "*** Verifying on R/W mumps.dat R/O mumps.mjl ***"
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip journal -verify -forward mumps.mjl"
$MUPIP journal -verify -forward mumps.mjl
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

echo "*** Verifying on R/O mumps.dat R/W mumps.mjl ***"
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "mupip journal -verify -forward mumps.mjl"
$MUPIP journal -verify -forward mumps.mjl
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

echo "*** Verifying on R/O mumps.dat R/O mumps.mjl ***"
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip journal -verify -forward mumps.mjl"
$MUPIP journal -verify -forward mumps.mjl
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

\rm -f mumps.dat mumps.mjl
