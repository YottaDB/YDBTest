#!/usr/local/bin/tcsh -f
echo ""
echo "*** TSTMJLREC.CSH ***"
echo ""
echo "*** Test for MUPIP JOURNAL -RECOVER -FORWARD ***"
# create_multi_jnl_db.csh used instead of dbcreate.csh
set verbose


$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod 666 *.dat *.mjl

\rm -f *.dat
$MUPIP create >& /dev/null
chmod.csh rwrw
$MUPIP journal -recover -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat
$MUPIP create >& /dev/null
chmod.csh rwro
$MUPIP journal -recover -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat
$MUPIP create >& /dev/null
chmod.csh rorw
$MUPIP journal -recover -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat
$MUPIP create >& /dev/null
chmod.csh roro
$MUPIP journal -recover -forward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl mumps.gld

echo "*** Test for MUPIP JOURNAL -RECOVER -BACKWARD ***"

$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod 666 *.dat *.mjl
chmod.csh rwrw
$MUPIP journal -recover -backward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh
chmod.csh rwro
$MUPIP journal -recover -backward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh
chmod.csh rorw
$MUPIP journal -recover -backward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh
chmod.csh roro
$MUPIP journal -recover -backward mumps.mjl,a.mjl,b.mjl,c.mjl
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl mumps.gld
