#!/usr/local/bin/tcsh -f
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
echo "*** TSTMBAKWJ.CSH ***"
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

mkdir ./Back
echo "*** *.dat R/W *.mjl R/W ***"
$MUPIP backup -noonline "*" ./Back | & sort -f
mipcmanage
$gtm_tst/com/dbcheck_filter.csh
\rm -f ./Back/*

echo "*** b.dat R/W b.mjl R/O ***"
chmod 666 b.dat
chmod 444 b.mjl
$MUPIP backup -noonline "*" ./Back | & sort -f
mipcmanage
$gtm_tst/com/dbcheck_filter.csh
\rm -f ./Back/*

echo "*** b.dat R/O b.mjl R/W ***"
chmod 444 b.dat
chmod 666 b.mjl
$MUPIP backup -noonline "*" ./Back | & sort -f
mipcmanage
$gtm_tst/com/dbcheck_filter.csh
\rm -f ./Back/*

echo "*** b.dat R/O b.mjl R/O ***"
chmod 444 b.dat
chmod 444 b.mjl
$MUPIP backup -noonline "*" ./Back | & sort -f
mipcmanage
$gtm_tst/com/dbcheck_filter.csh
\rm -rf Back

\rm -f *.dat *.mjl mumps.gld


