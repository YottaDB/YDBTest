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
#Tests of mupip command "EXTRACT" with no journal no freeze
echo ""
echo "*** TSTEXTRNJ.CSH ***"
echo ""

# dbcreate.csh not used because we re-use part of what was created in tstcreate.csh
$MUPIP create
chmod 666 mumps.dat
lsmumps

setenv GTM "$gtm_exe/mumps -direct"

$GTM<<aaa
w "do init",!  d ^init
aaa

echo "mupip extract -nolog glo.dir"
$MUPIP extract -nolog glo.dir
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

echo "***** changing mumps.dat to read_only *****"
chmod 444 mumps.dat
lsmumps
/bin/rm -f glo.dir


echo "mupip extract -nolog glo.dir"
$MUPIP extract -nolog glo.dir
ipcmanage
$gtm_tst/com/dbcheck_filter.csh

/bin/rm -f mumps.dat glo.dir
