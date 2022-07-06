#!/usr/local/bin/tcsh -f
#Test MUPIP SET /FILE
echo ""
echo "*** TSTMSETF.CSH ***"
echo ""
\rm -f *.gld *.dat *.mjl
# create_multi_jnl_db.csh used instead of dbcreate.csh
set verbose

$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod.csh rwrw
$MUPIP set -file a.dat -journal=enable,on,before
$MUPIP set -file b.dat -journal=enable,on,before
$MUPIP set -file c.dat -journal=enable,on,before
$MUPIP set -file mumps.dat -journal=enable,on,before
$gtm_tst/com/dbcheck.csh
\rm -f *.dat *.mjl



$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod.csh rwro
$MUPIP set -file a.dat -journal=enable,on,before
$MUPIP set -file b.dat -journal=enable,on,before
$MUPIP set -file c.dat -journal=enable,on,before
$MUPIP set -file mumps.dat -journal=enable,on,before
$gtm_tst/com/dbcheck.csh
\rm -f *.dat *.mjl


$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod.csh rorw
$MUPIP set -file a.dat -journal=enable,on,before
$MUPIP set -file b.dat -journal=enable,on,before
$MUPIP set -file c.dat -journal=enable,on,before
$MUPIP set -file mumps.dat -journal=enable,on,before
$gtm_tst/com/dbcheck.csh
\rm -f *.dat *.mjl

$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod.csh roro
$MUPIP set -file a.dat -journal=enable,on,before
$MUPIP set -file b.dat -journal=enable,on,before
$MUPIP set -file c.dat -journal=enable,on,before
$MUPIP set -file mumps.dat -journal=enable,on,before
$gtm_tst/com/dbcheck.csh
\rm -f *.dat *.mjl
