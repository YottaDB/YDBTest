#! /usr/local/bin/tcsh -f
# Integ test /file
echo ""
echo "*** TSTINTEGF.CSH ***"
echo ""

$MUPIP create
lsmumps

echo ""
echo "First with no journal"
echo ""
setenv GTM "$gtm_exe/mumps -direct"
$GTM <<aaa
w "do init",!  d ^init
aaa

echo "mupip integ -FAST mumps.dat"
$MUPIP integ -FAST mumps.dat
echo "mupip integ -file mumps.dat"
$MUPIP integ -file mumps.dat
ipcmanage


echo "***** mumps.dat R/O *****"
chmod 444 mumps.dat
lsmumps
echo "mupip integ -FAST mumps.dat "
$MUPIP integ -FAST mumps.dat
echo "mupip integ -file mumps.dat"
$MUPIP integ -file mumps.dat
ipcmanage


echo ""
echo "Now with journal"
echo ""
/bin/rm -f mumps.dat mumps.mjl


echo "***** mumps.dat R/W mumps.mjl R/W *****"
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM <<xyz
w "do init",!  d ^init
xyz

echo "mupip integ -FAST mumps.dat "
$MUPIP integ -FAST mumps.dat
echo "mupip integ -file mumps.dat"
$MUPIP integ -file mumps.dat
ipcmanage

echo "***** mumps.dat R/W mumps.mjl R/O *****"
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip integ -FAST mumps.dat "
$MUPIP integ -FAST mumps.dat
echo "mupip integ -file mumps.dat"
$MUPIP integ -file mumps.dat
ipcmanage


echo "***** mumps.dat R/O mumps.mjl R/W *****"
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "mupip integ -FAST mumps.dat "
$MUPIP integ -FAST mumps.dat
echo "mupip integ -file mumps.dat"
$MUPIP integ -file mumps.dat
ipcmanage

echo "***** mumps.dat R/O mumps.mjl R/O *****"
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip integ -FAST mumps.dat "
$MUPIP integ -FAST mumps.dat
echo "mupip integ -file mumps.dat"
$MUPIP integ -file mumps.dat
ipcmanage


/bin/rm -f mumps.dat mumps.mjl
