#! /usr/local/bin/tcsh -f
#Tests of mupip command "LOAD" on a read_only database file
echo ""
echo "*** TSTLOAD.CSH ***"
echo ""

# dbcreate.csh not used since we re-use the database created by tstcreate.csh
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps

setenv GTM "$gtm_exe/mumps -direct"
$GTM << EOF
w "do init",!
d ^init
EOF

echo "*****  mumps.dat R/W mumps.mjl R/W *****"
echo "mupip load -begin=3 -end=5 load.go1"
$MUPIP load -begin=3 -end=5 load.go1
echo "mupip load load.go1"
$MUPIP load load.go1
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "*****  mumps.dat R/W mumps.mjl R/O *****"
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip load load.go2"
$MUPIP load load.go2
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "*****  mumps.dat R/O mumps.mjl R/W *****"
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "mupip load load.go3"
$MUPIP load load.go3
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "*****  mumps.dat R/O mumps.mjl R/O *****"
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip load load.go2"
$MUPIP load load.go2
ipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f mumps.dat mumps.mjl
