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
echo ""
echo "*** TSTMJLVERI.CSH ***"
echo ""
echo "*** Test for MUPIP JOURNAL -VERIFY ***"
# create_multi_jnl_db.csh used instead of dbcreate.csh
set verbose

$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod 666 *.dat *.mjl

chmod.csh rwrw
$MUPIP journal -verify -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

chmod.csh rwro
$MUPIP journal -verify -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

chmod.csh rorw
$MUPIP journal -verify -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

chmod.csh roro
$MUPIP journal -verify -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly

\rm -f *.dat *.mjl mumps.gld
