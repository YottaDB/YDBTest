#! /usr/local/bin/tcsh -f
#Tests of mupip command "INTEG /REG" on a read_only database file
echo ""
echo "*** TSTINTEGR.CSH ***"
echo ""
echo "*** First database with no journal***"
echo ""


$MUPIP create
setenv GTM "$gtm_exe/mumps -direct"
$GTM <<aaa
w "do init",!  d ^init
aaa

echo "***** mumps.dat R/W *****"
lsmumps
echo "mupip integ -region DEFAULT"
$MUPIP integ -region DEFAULT
echo "mupip integ mumps.dat"
$MUPIP integ mumps.dat
ipcmanage




echo "***** mumps.dat R/O *****"
chmod 444 mumps.dat
lsmumps
echo "mupip integ -region DEFAULT"
$MUPIP integ -region DEFAULT
echo "mupip integ mumps.dat"
$MUPIP integ mumps.dat
ipcmanage

/bin/rm -f mumps.dat mumps.mjl
echo "*** Now database with journal***"
echo "***** mumps.dat R/W  mumps.mjl R/W *****"
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM <<xyz
w "do init",!  d ^init
xyz
echo "mupip integ -region DEFAULT"
$MUPIP integ -region DEFAULT
ipcmanage
echo "mupip integ mumps.dat"
$MUPIP integ mumps.dat
ipcmanage




echo ""
echo "***** mumps.dat R/W  mumps.mjl R/O *****"
echo ""
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip integ -region DEFAULT"
$MUPIP integ -region DEFAULT
echo "mupip integ mumps.dat"
$MUPIP integ mumps.dat
ipcmanage



echo ""
echo "***** mumps.dat R/O  mumps.mjl R/W *****"
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "mupip integ -region DEFAULT"
$MUPIP integ -region DEFAULT
echo "mupip integ mumps.dat"
$MUPIP integ mumps.dat
ipcmanage



echo ""
echo "***** mumps.dat R/O  mumps.mjl R/O *****"
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
echo "mupip integ -region DEFAULT"
$MUPIP integ -region DEFAULT
echo "mupip integ mumps.dat"
$MUPIP integ mumps.dat
ipcmanage

/bin/rm -f mumps.dat mumps.mjl
