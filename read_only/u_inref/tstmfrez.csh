#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#Tests of mupip command "FREEZE" on a read_only database file
echo ""
echo "*** TSTMFREZ.CSH ***"
echo ""
# create_multi_jnl_db.csh used instead of dbcreate.csh
set verbose

$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod 666 *.dat *.mjl

echo "***** *.dat R/W  *.mjl R/W *****"
echo mupip freeze -on "*"
$MUPIP freeze -on "*" >& freeze_on_all.out
mipcmanage
echo mupip freeze -off "*"
$MUPIP freeze -off "*" >& freeze_off_all.out
mipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

echo "***** b.dat R/W  b.mjl R/O *****"
chmod 666 b.dat
chmod 444 b.mjl
echo mupip freeze -on "*"
$MUPIP freeze -on "*" >& freeze1_on_all.out
mipcmanage
echo mupip freeze -off "*"
$MUPIP freeze -off "*" >& freeze1_off_all.out
mipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

echo "***** b.dat R/O  b.mjl R/W *****"
chmod 444 b.dat
chmod 666 b.mjl
echo mupip freeze -on "*"
$MUPIP freeze -on "*" >& freeze2_on_all.outx
$gtm_tst/com/check_error_exist.csh freeze2_on_all.outx "YDB-E-DBRDONLY"
mipcmanage
echo mupip freeze -off "*"
$MUPIP freeze -off "*" >& freeze2_off_all.outx
$gtm_tst/com/check_error_exist.csh freeze2_off_all.outx "YDB-E-DBRDONLY"
mipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

echo "***** b.dat R/O  b.mjl R/O *****"
chmod 444 b.dat
chmod 444 b.mjl
echo mupip freeze -on "*"
$MUPIP freeze -on "*" >& freeze3_on_all.outx
$gtm_tst/com/check_error_exist.csh freeze3_on_all.outx "YDB-E-DBRDONLY"
mipcmanage
echo mupip freeze -off "*"
$MUPIP freeze -off "*" >& freeze3_off_all.outx
$gtm_tst/com/check_error_exist.csh freeze3_off_all.outx "YDB-E-DBRDONLY"
mipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

\rm -f *.dat *.mjl mumps.gld
