#!/usr/local/bin/tcsh -f
#Tests of mupip command "RESTORE" on a read_only database file
echo ""
echo "*** TSTMRESTORE.CSH ***"
echo ""
# create_multi_jnl_db.csh used instead of dbcreate.csh
set verbose

$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod 666 *.dat *.mjl

mkdir ./backup
$MUPIP backup -noonline -i "*" ./backup | & sort -f
$gtm_tst/com/dbcheck.csh

\rm -f *.dat
$MUPIP create
chmod.csh rwrw
res mumps.dat a.dat b.dat c.dat
$gtm_tst/com/dbcheck.csh

\rm -f *.dat
$MUPIP create
chmod.csh rwro
res mumps.dat a.dat b.dat c.dat
$gtm_tst/com/dbcheck.csh

\rm -f *.dat
$MUPIP create
chmod.csh rorw
res mumps.dat a.dat b.dat c.dat
$gtm_tst/com/dbcheck.csh

\rm -f *.dat
$MUPIP create
chmod.csh roro
res mumps.dat a.dat b.dat c.dat
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl mumps.gld
\rm -fr backup
