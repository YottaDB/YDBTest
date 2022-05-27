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
echo "*** TSTMJLSH.CSH ***"
echo ""
echo "*** Test for MUPIP JOURNAL -SHOW ***"
# create_multi_jnl_db.csh use instead of dbcreate.csh
set verbose

$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << EOF
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
EOF
chmod 666 *.dat *.mjl

chmod.csh rwrw
$MUPIP journal -show=all -forward mumps.mjl,a.mjl,b.mjl,c.mjl >& jlsh1.out
mipcmanage
$gtm_tst/com/dbcheck_filter.csh

chmod.csh rwro
$MUPIP journal -show=all -forward mumps.mjl,a.mjl,b.mjl,c.mjl >& jlsh2.out
mipcmanage
$gtm_tst/com/dbcheck_filter.csh

chmod.csh rorw
$MUPIP journal -show=all -forward mumps.mjl,a.mjl,b.mjl,c.mjl >& jlsh3.out
mipcmanage
$gtm_tst/com/dbcheck_filter.csh

chmod.csh roro
$MUPIP journal -show=all -forward mumps.mjl,a.mjl,b.mjl,c.mjl >& jlsh4.out
mipcmanage
$gtm_tst/com/dbcheck_filter.csh

$grep successful jlsh*.out
\rm -f jlsh*.out *.dat *.mjl mumps.gld
