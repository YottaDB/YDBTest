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
#Test MUPIP SET /REGION
set read_only_awkfile = $gtm_tst/$tst/u_inref/awkfile
echo ""
echo "*** TSTSETR.CSH ***"
echo ""

# dbcreate.csh not used since we re-use the database created in tstcreate.csh
echo "*** Initializing....  and creating a normal (r+w) database ***"
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl

echo "*** R/W mumps.dat R/W mumps.mjl ***"
lsmumps
echo "$MUPIP set -region DEFAULT -journal=enable,on,before"
$MUPIP set -file mumps.dat -journal=enable,on,before
lsmumps
ipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly
\rm -f mumps.dat* mumps.mjl*

echo "*** Reinitializing....  and creating a normal (r+w) database ***"
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 444 mumps.mjl
echo "*** R/W mumps.dat R/O mumps.mjl ***"
lsmumps
echo "$MUPIP set -region DEFAULT -journal=enable,on,before"
$MUPIP set -region DEFAULT -journal=enable,on,before
ipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly
\rm -f mumps.dat* mumps.mjl*

echo "*** Reinitializing....  and creating a normal (r+w) database ***"
\cp -f  tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 444 mumps.dat
chmod 666 mumps.mjl
echo "*** R/O mumps.dat R/W mumps.mjl ***"
lsmumps
echo "$MUPIP set -region DEFAULT -journal=enable,on,before"
$MUPIP set -region DEFAULT -journal=enable,on,before
ipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly
\rm -f mumps.dat* mumps.mjl*

echo "*** Reinitializing....  and creating a normal (r+w) database ***"
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 444 mumps.dat
chmod 444 mumps.mjl
echo "*** R/O mumps.dat R/O mumps.mjl ***"
lsmumps
echo "$MUPIP set -region DEFAULT -journal=enable,on,before"
$MUPIP set -region DEFAULT -journal=enable,on,before
ipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly
\rm -f mumps.dat* mumps.mjl*
