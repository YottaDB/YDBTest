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
#Tests of mupip command "BACK" on a read_only database file
echo ""
echo "*** TSTBAKNJ ***"
echo ""
# dbcreate.csh not used because we re-use some of what was done inside tstcreate.csh.
$MUPIP create
chmod 666 mumps.dat
lsmumps

echo "mupip backup -noonline DEFAULT back.dat"
$MUPIP backup -noonline DEFAULT back.dat
ipcmanage

$gtm_tst/com/dbcheck_filter.csh
$gtm_tst/com/dbcheck_filter.csh back
\rm -f back.dat

echo "***** changing mumps.dat to read_only *****"
chmod 444 mumps.dat
lsmumps
echo "mupip backup -noonline DEFAULT back.dat"
$MUPIP backup -noonline DEFAULT back.dat
ipcmanage
$gtm_tst/com/dbcheck_filter.csh
\rm -f back.dat
