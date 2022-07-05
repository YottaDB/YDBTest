#! /usr/local/bin/tcsh -f
echo "*** TSTJLREC.CSH ***"
echo ""
echo "*** Test for MUPIP JOURNAL -RECOVER ***"

# dbcreate.csh not used because we re-use the dabatase create in tstcreate.csh
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
setenv GTM "$gtm_exe/mumps -direct"
$GTM << EOF
w "do init",!  d ^init
EOF
echo "*** Recovering on R/W mumps.dat R/W mumps.mjl ***"
lsmumps
\rm mumps.dat
$MUPIP create
echo "mupip journal -recover -forward mumps.mjl"
$MUPIP journal -recover -forward mumps.mjl
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "*** Recovering on R/W mumps.dat R/O mumps.mjl ***"
\rm mumps.dat
$MUPIP create
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip journal -recover -forward mumps.mjl"
$MUPIP journal -recover  -forward mumps.mjl
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "*** Recovering on R/O mumps.dat R/W mumps.mjl ***"
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "mupip journal -recover -forward mumps.mjl"
$MUPIP journal -recover  -forward mumps.mjl
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "*** Recovering on R/O mumps.dat R/O mumps.mjl ***"
chmod 444 mumps.mjl
chmod 444 mumps.dat
lsmumps
echo "mupip journal -recover -forward mumps.mjl"
$MUPIP journal -recover  -forward mumps.mjl
ipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f mumps.dat mumps.mjl
