#! /usr/local/bin/tcsh -f
echo ""
echo "*** TSTJLVERI.CSH ***"
echo ""
echo "*** Test for MUPIP JOURNAL -VERIFY ***"
setenv GTM "$gtm_exe/mumps -direct"

# dbcreate.csh not used because we re-use the database created in tstcreate.csh
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM << EOF
w "do init",!  d ^init
EOF

echo "*** Verifying on R/W mumps.dat R/W mumps.mjl ***"
echo "mupip journal -verify -forward mumps.mjl"
$MUPIP journal -verify -forward mumps.mjl
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "*** Verifying on R/W mumps.dat R/O mumps.mjl ***"
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip journal -verify -forward mumps.mjl"
$MUPIP journal -verify -forward mumps.mjl
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "*** Verifying on R/O mumps.dat R/W mumps.mjl ***"
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "mupip journal -verify -forward mumps.mjl"
$MUPIP journal -verify -forward mumps.mjl
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "*** Verifying on R/O mumps.dat R/O mumps.mjl ***"
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip journal -verify -forward mumps.mjl"
$MUPIP journal -verify -forward mumps.mjl
ipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f mumps.dat mumps.mjl
