#!/usr/local/bin/tcsh -f
#Tests of mupip command "EXTRACT" with no journal with freeze
echo ""
echo "*** TSTMEXTRNJWFR.CSH ***"
echo ""
set verbose

$gtm_tst/com/dbcreate.csh mumps $1
$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod 666 *.dat

echo "mupip extract -fr -nolog glo.dir"
$MUPIP extract -fr -nolog glo.dir | & sort -f
mipcmanage
$gtm_tst/com/dbcheck.csh
\rm -f glo.dir

echo "***** changing *.dat to read_only *****"
chmod 444 *.dat
echo "mupip extract -fr -nolog glo.dir"
$MUPIP extract -fr -nolog glo.dir | & sort -f
$gtm_tst/com/dbcheck.csh
mipcmanage

\rm -f *.dat glo.dir mumps.gld
