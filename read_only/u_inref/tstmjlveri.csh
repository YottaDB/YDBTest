#!/usr/local/bin/tcsh -f
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
$gtm_tst/com/dbcheck.csh

chmod.csh rwro
$MUPIP journal -verify -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh

chmod.csh rorw
$MUPIP journal -verify -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh

chmod.csh roro
$MUPIP journal -verify -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl mumps.gld
