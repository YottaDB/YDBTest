#! /usr/local/bin/tcsh -f
#Tests of mupip command "EXTRACT" with journal with freeze
echo ""
echo "*** TSTEXTRWJWFR.CSH ***"
echo ""

# dbcreate.csh not called because we re-use the database created in tstcreate.csh
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "**** mumps.dat R/W mumps.mjl R/W ***"
setenv GTM "$gtm_exe/mumps -direct"
$GTM << EOF
w "do init",!  d ^init
EOF
echo "mupip extract -fr -nolog glo.dir"
$MUPIP extract -fr -nolog glo.dir
ipcmanage
$gtm_tst/com/dbcheck.csh

/bin/rm -f glo.dir
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "**** mumps.dat R/W mumps.mjl R/O ***"
echo "mupip extract -fr -nolog glo.dir"
$MUPIP extract -fr -nolog glo.dir
ipcmanage
$gtm_tst/com/dbcheck.csh

/bin/rm -f glo.dir
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "**** mumps.dat R/O mumps.mjl R/W ***"
echo "mupip extract -fr -nolog glo.dir"
$MUPIP extract -fr -nolog glo.dir
ipcmanage
$gtm_tst/com/dbcheck.csh

/bin/rm -f glo.dir
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "**** mumps.dat R/O mumps.mjl R/O ***"
echo "mupip extract -fr -nolog glo.dir"
$MUPIP extract -fr -nolog glo.dir
ipcmanage
$gtm_tst/com/dbcheck.csh

/bin/rm -f mumps.dat mumps.mjl glo.dir
