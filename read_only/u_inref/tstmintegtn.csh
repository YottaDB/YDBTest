#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	#
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

#Tests of mupip command "INTEG-/tn_reset" on a read_only database and/or journal files

echo ""
echo "*** TSTMINTEGTN.CSH ***"
echo ""
echo "*** First database with no journal***"
echo ""
set verbose

$gtm_tst/com/dbcreate.csh mumps $1
$GTM <<aaa
w "do in0^sfill(""set"",1,$1)",!  do in0^sfill("set",1,$1)
aaa
chmod 666 b.dat

echo "***** *.dat read_write *****"
$gtm_tst/$tst/u_inref/tstmintegtn_domultireg.csh | & sort >& integtn.out1
$grep -E "YDB-E|No errors" integtn.out1
mipcmanage

echo "***** b.dat read_only *****"
chmod 444 b.dat
$gtm_tst/$tst/u_inref/tstmintegtn_domultireg.csh | & sort >& integtn.out2
$grep -E "YDB-E|No errors" integtn.out2
mipcmanage
\rm -f *.dat

echo ""
echo "*** Now database with journal***"
echo ""

$MUPIP create
$MUPIP set -journal=enable,on,before -reg "*" | & sort -f
$GTM <<aaa
w "do in0^sfill(""set"",1,$1)",!  do in0^sfill("set",1,$1)
aaa
chmod 666 *.dat *.mjl

chmod.csh rwrw
$gtm_tst/$tst/u_inref/tstmintegtn_domultireg.csh | & sort >& integtn.out3
$grep -E "YDB-E|No errors" integtn.out3
mipcmanage

chmod.csh rwro
$gtm_tst/$tst/u_inref/tstmintegtn_domultireg.csh | & sort >& integtn.out4
$grep -E "YDB-E|No errors" integtn.out4
mipcmanage

chmod.csh rorw
$gtm_tst/$tst/u_inref/tstmintegtn_domultireg.csh | & sort >& integtn.out5
$grep -E "YDB-E|No errors" integtn.out5
mipcmanage

chmod.csh roro
$gtm_tst/$tst/u_inref/tstmintegtn_domultireg.csh | & sort >& integtn.out6
$grep -E "YDB-E|No errors" integtn.out6
mipcmanage

chmod 666 *.dat *.mjl
$gtm_tst/com/dbcheck.csh
\rm -f *.dat *.mjl mumps.gld
