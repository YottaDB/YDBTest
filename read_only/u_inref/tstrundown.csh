#! /usr/local/bin/tcsh -f
echo "*** Test for mupip command RUNDOWN ***"
echo ""
echo "*** TSTRUNDOWN ***"
echo ""
setenv GTM "$gtm_exe/mumps -direct"

# dbcreate.csh not used since we re-use the database created by tstcreate.csh
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM << EOF
w "do init",!  d ^init
EOF
echo "**** R/W mumps.dat R/W mumps.mjl ****"
echo "mupip rundown -f mumps.dat"
$MUPIP rundown -f mumps.dat
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "**** R/W mumps.dat R/O mumps.mjl ****"
chmod 444 mumps.mjl
lsmumps
echo "mupip rundown -f mumps.dat"
$MUPIP rundown -f mumps.dat
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "**** R/O mumps.dat R/W mumps.mjl ****"
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "mupip rundown -f mumps.dat"
$MUPIP rundown -f mumps.dat
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "**** R/O mumps.dat R/O mumps.mjl ****"
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip rundown -f mumps.dat"
$MUPIP rundown -f mumps.dat
ipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f mumps.dat mumps.mjl
