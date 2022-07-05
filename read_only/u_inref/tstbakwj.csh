#! /usr/local/bin/tcsh -f
#Tests of mupip command "BACK" on a read_only database file
alias dbcheck '$gtm_tst/com/dbcheck.csh ;$gtm_tst/com/dbcheck.csh back ; \rm -f back.dat '
echo ""
echo "*** TSTBAKWJ.CSH ***"
echo ""

# dbcreate.csh not used because we re-use the database created in tstcreate.csh
cp -f tmumps.dat mumps.dat
cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
echo "*** mumps.dat R/W mumps.mjl R/W ***"
$MUPIP backup -noonline DEFAULT back.dat
ipcmanage
dbcheck

echo "*** mumps.dat R/W mumps.mjl R/O ***"
cp -f tmumps.dat mumps.dat
cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 444 mumps.mjl
lsmumps
$MUPIP backup -noonline DEFAULT back.dat
ipcmanage
dbcheck

echo "*** mumps.dat R/O mumps.mjl R/W ***"
cp -f tmumps.dat mumps.dat
cp -f tmumps.mjl mumps.mjl
chmod 444 mumps.dat
chmod 666 mumps.mjl
lsmumps
$MUPIP backup -noonline DEFAULT back.dat
ipcmanage

echo "*** mumps.dat R/O mumps.mjl R/O ***"
cp -f tmumps.dat mumps.dat
cp -f tmumps.mjl mumps.mjl
chmod 444 mumps.dat
chmod 444 mumps.mjl
lsmumps
$MUPIP backup -noonline DEFAULT back.dat
ipcmanage
\rm -f mumps.dat mumps.mjl back
