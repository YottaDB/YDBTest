#!/usr/local/bin/tcsh -f
#Tests of mupip command "EXTEND" on a read_only database file
echo ""
echo "*** TSTMEXTE.CSH ****"
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

echo "***** *.dat R/W  *.mjl R/W *****"
$MUPIP extend DEFAULT
mipcmanage
$MUPIP extend AREG
mipcmanage
$MUPIP extend BREG
mipcmanage
$MUPIP extend CREG
mipcmanage
$gtm_tst/com/dbcheck.csh

echo "***** b.dat R/W  b.mjl R/O *****"
chmod 666 b.dat
chmod 444 b.mjl
$MUPIP extend DEFAULT
mipcmanage
$MUPIP extend AREG
mipcmanage
$MUPIP extend BREG
mipcmanage
$MUPIP extend CREG
mipcmanage
$gtm_tst/com/dbcheck.csh

echo "***** b.dat R/O  b.mjl R/W *****"
chmod 444 b.dat
chmod 666 b.mjl
$MUPIP extend DEFAULT
mipcmanage
$MUPIP extend AREG
mipcmanage
$MUPIP extend BREG
mipcmanage
$MUPIP extend CREG
mipcmanage
$gtm_tst/com/dbcheck.csh

echo "***** b.dat R/O  b.mjl R/O *****"
chmod 444 b.dat
chmod 444 b.mjl
$MUPIP extend DEFAULT
mipcmanage
$MUPIP extend AREG
mipcmanage
$MUPIP extend BREG
mipcmanage
$MUPIP extend CREG
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl mumps.gld
