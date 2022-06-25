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
#Test MUPIP SET /FILE
set read_only_awkfile = $gtm_tst/$tst/u_inref/awkfile
echo ""
echo "*** TSTMSETR.CSH ***"
echo ""
\rm -f *.gld *.dat *.mjl*
# create_multi_jnl_db.csh used instead of dbcreate.csh
set verbose

$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod.csh rwrw
$MUPIP set -reg "*" -journal=enable,on,before | & sort -f
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly
\rm -f *.gld *.dat *.mjl*



$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod.csh rwro
$MUPIP set -reg "*" -journal=enable,on,before | & sort -f
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly
\rm -f *.gld *.dat *.mjl*


$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod.csh rorw
$MUPIP set -reg "*" -journal=enable,on,before | & sort -f
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly
\rm -f *.gld *.dat *.mjl*

$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod.csh roro
$MUPIP set -reg "*" -journal=enable,on,before | & sort -f
$gtm_tst/com/dbcheck_filter.csh -nodbfilerdonly
\rm -f *.gld *.dat *.mjl*
