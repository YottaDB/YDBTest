#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "*** Test for mupip command RUNDOWN ***"
echo ""
echo "*** TSTRUNDOWN ***"
echo ""
setenv GTM "$gtm_exe/mumps -direct"

# dbcreate.csh not used since we re-use the database created by tstcreate.csh
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM << EOF
w "do init",!  d ^init
EOF
echo "**** R/W mumps.dat R/W mumps.mjl ****"
echo "mupip rundown -f mumps.dat"
$MUPIP rundown -f mumps.dat
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

echo "**** R/W mumps.dat R/O mumps.mjl ****"
chmod 444 mumps.mjl
lsmumps
echo "mupip rundown -f mumps.dat"
$MUPIP rundown -f mumps.dat
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

echo "**** R/O mumps.dat R/W mumps.mjl ****"
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "mupip rundown -f mumps.dat"
$MUPIP rundown -f mumps.dat	# rundown cannot clean ipcs since mumps.dat is read-only
chmod +w mumps.dat		# give write permissions and retry rundown
$MUPIP rundown -f mumps.dat
ipcmanage			# now check ipc status
$gtm_tst/com/dbcheck_filter.csh

echo "**** R/O mumps.dat R/O mumps.mjl ****"
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip rundown -f mumps.dat"
$MUPIP rundown -f mumps.dat	# rundown cannot clean ipcs since mumps.dat is read-only
chmod +w mumps.dat		# give write permissions and retry rundown
$MUPIP rundown -f mumps.dat
ipcmanage			# now check ipc status
$gtm_tst/com/dbcheck_filter.csh

\rm -f mumps.dat mumps.mjl
