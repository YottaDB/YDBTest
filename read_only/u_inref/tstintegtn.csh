#! /usr/local/bin/tcsh -f
#Tests of mupip command "INTEG-/tn_reset" on a read_only database and/or journal files

echo ""
echo "*** TSTINTEGTN.CSH ***"
echo ""
echo "*** First database with no journal***"
echo ""


$MUPIP create
setenv GTM "$gtm_exe/mumps -direct"
$GTM <<aaa
w "do init",!  d ^init
aaa

echo "***** mumps.dat read_write *****"
lsmumps
echo "mupip integ -tn_reset mumps.dat"
$MUPIP integ -tn_reset mumps.dat
ipcmanage


echo "***** mumps.dat read_only *****"
chmod 444 mumps.dat
lsmumps
echo "mupip integ -tn_reset mumps.dat "
$MUPIP integ -tn_reset mumps.dat
ipcmanage


echo ""
echo "*** Now database with journal***"
echo ""

/bin/rm -f mumps.dat mumps.mjl
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM <<aaa
w "do init",!  d ^init
aaa
echo "**** R/W mumps.dat R/W mumps.mjl ****"
lsmumps
echo "mupip integ - tn_reset mumps.dat "
$MUPIP integ -tn_reset mumps.dat
ipcmanage



echo "**** R/W mumps.dat R/O mumps.mjl ****"
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip integ - tn_reset mumps.dat "
$MUPIP integ -tn_reset mumps.dat
ipcmanage



echo "**** R/O mumps.dat R/W mumps.mjl ****"
chmod 666 mumps.mjl
chmod 444 mumps.dat
lsmumps
echo "mupip integ -tn_reset mumps.dat "
$MUPIP integ -tn_reset mumps.dat
ipcmanage



echo "**** R/O mumps.dat R/O mumps.mjl ****"
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip integ -tn_reset mumps.dat "
$MUPIP integ -tn_reset mumps.dat
ipcmanage

/bin/rm -f mumps.dat mumps.mjl
