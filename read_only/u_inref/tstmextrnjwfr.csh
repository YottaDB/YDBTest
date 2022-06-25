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
#Tests of mupip command "EXTRACT" with no journal with freeze
echo ""
echo "*** TSTMEXTRNJWFR.CSH ***"
echo ""
set verbose

$gtm_tst/com/dbcreate.csh mumps $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod 666 *.dat

echo "mupip extract -fr -nolog glo.dir"
$MUPIP extract -fr -nolog glo.dir | & sort -f
mipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly
\rm -f glo.dir

echo "***** changing *.dat to read_only *****"
chmod 444 *.dat
echo "mupip extract -fr -nolog glo.dir"
$MUPIP extract -fr -nolog glo.dir | & sort -f
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly
mipcmanage

\rm -f *.dat glo.dir mumps.gld
