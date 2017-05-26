#!/usr/local/bin/tcsh -f
echo "*** Test for mupip command RUNDOWN ***"
echo ""
echo "*** TSTMRUNDOWN ***"
echo ""
# create_multi_jnl_db.csh used instead of dbcreate.csh
set verbose

$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
d in0^sfill("set",1,$1)
h
bbb
chmod 666 *.dat *.mjl

chmod.csh rwrw
echo "mupip rundown -reg * "
$MUPIP rundown -reg "*" | & sort -f
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
d in0^sfill("set",1,$1)
h
bbb
chmod.csh rwro
echo "mupip rundown -reg * "
$MUPIP rundown -reg "*" | & sort -f
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
d in0^sfill("set",1,$1)
h
bbb
chmod.csh rorw
echo "mupip rundown -reg * "
$MUPIP rundown -reg "*" | & sort -f
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
d in0^sfill("set",1,$1)
h
bbb
chmod.csh roro
echo "mupip rundown -reg * "
$MUPIP rundown -reg "*" | & sort -f
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl mumps.gld
