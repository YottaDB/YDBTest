#! /usr/local/bin/tcsh -f
echo ""
echo "*** TSTJLSH.CSH ***"
echo ""
echo "*** Test for MUPIP JOURNAL -SHOW ***"
setenv GTM "$gtm_exe/mumps -direct"

# dbcreate.csh not used because we re-use the database created by tstcreate.csh
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM << EOF
w "do init",!  d ^init
EOF

echo "*** Showing on R/W mumps.dat R/W mumps.mjl ***"
lsmumps
echo "mupip journal -show=all -forward mumps.mjl >& jlsh1.out"
$MUPIP journal -show=all -forward mumps.mjl >& jlsh1.out
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "*** Showing on R/W mumps.dat R/O mumps.mjl ***"
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip journal -show=all -forward mumps.mjl >& jlsh2.out"
$MUPIP journal -show=all -forward mumps.mjl >& jlsh2.out
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "*** Showing on R/O mumps.dat R/W mumps.mjl ***"
chmod 444 mumps.dat
chmod 666 mumps.dat
lsmumps
echo "mupip journal -show=all -forward mumps.mjl >& jlsh3.out"
$MUPIP journal -show=all -forward mumps.mjl >& jlsh3.out
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "*** Showing on R/O mumps.dat R/O mumps.mjl ***"
chmod 444 mumps.mjl
chmod 444 mumps.dat
lsmumps
echo "mupip journal -show=all -forward mumps.mjl >& jlsh4.out"
$MUPIP journal -show=all -forward mumps.mjl >& jlsh4.out
ipcmanage
$gtm_tst/com/dbcheck.csh

$grep successful jlsh*.out
\rm -f mumps.dat mumps.mjl
