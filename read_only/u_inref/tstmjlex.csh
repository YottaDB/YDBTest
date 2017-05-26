#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "*** Test for MUPIP JOURNAL -EXTRACT ***"

# create_multi_jnl_db.csh used instead of dbcreate.csh
echo ""
echo "*** TSTMJLEX.CSH ***"
echo ""
set verbose
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
d in0^sfill("set",1,$1)
h
bbb
chmod.csh rwrw
$MUPIP journal -extract=mumps.mjf -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh
\rm -f *.mjf

chmod.csh rwro
$MUPIP journal -extract=mumps.mjf -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh
\rm -f *.mjf

chmod.csh rorw
$MUPIP journal -extract=mumps.mjf -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh
\rm -f *.mjf

chmod.csh roro
$MUPIP journal -extract=mumps.mjf -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh
\rm -f *.mjf

\rm -f *.dat *.mjl mumps.gld
