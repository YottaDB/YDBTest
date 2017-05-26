#!/usr/local/bin/tcsh -f
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
$gtm_tst/com/dbcheck.csh

chmod.csh rwro
$MUPIP journal -show=all -forward mumps.mjl,a.mjl,b.mjl,c.mjl >& jlsh2.out
mipcmanage
$gtm_tst/com/dbcheck.csh

chmod.csh rorw
$MUPIP journal -show=all -forward mumps.mjl,a.mjl,b.mjl,c.mjl >& jlsh3.out
mipcmanage
$gtm_tst/com/dbcheck.csh

chmod.csh roro
$MUPIP journal -show=all -forward mumps.mjl,a.mjl,b.mjl,c.mjl >& jlsh4.out
mipcmanage
$gtm_tst/com/dbcheck.csh

$grep successful jlsh*.out
\rm -f jlsh*.out *.dat *.mjl mumps.gld
