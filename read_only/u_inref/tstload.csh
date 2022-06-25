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
#Tests of mupip command "LOAD" on a read_only database file
echo ""
echo "*** TSTLOAD.CSH ***"
echo ""

# dbcreate.csh not used since we re-use the database created by tstcreate.csh
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps

setenv GTM "$gtm_exe/mumps -direct"
$GTM << EOF
w "do init",!
d ^init
EOF

echo "*****  mumps.dat R/W mumps.mjl R/W *****"
echo "mupip load -begin=3 -end=5 load.go1"
$MUPIP load -begin=3 -end=5 load.go1
echo "mupip load load.go1"
$MUPIP load load.go1
ipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

echo "*****  mumps.dat R/W mumps.mjl R/O *****"
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip load load.go2"
$MUPIP load load.go2
ipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

echo "*****  mumps.dat R/O mumps.mjl R/W *****"
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "mupip load load.go3"
$MUPIP load load.go3
ipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

echo "*****  mumps.dat R/O mumps.mjl R/O *****"
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip load load.go2"
$MUPIP load load.go2
ipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

\rm -f mumps.dat mumps.mjl
