#! /usr/local/bin/tcsh -f
#Tests of mupip command "BACK" on a read_only database file
echo ""
echo "*** TSTBAKNJ ***"
echo ""
# dbcreate.csh not used because we re-use some of what was done inside tstcreate.csh.
$MUPIP create
chmod 666 mumps.dat
lsmumps

echo "mupip backup -noonline DEFAULT back.dat"
$MUPIP backup -noonline DEFAULT back.dat
ipcmanage

$gtm_tst/com/dbcheck.csh
$gtm_tst/com/dbcheck.csh back
\rm -f back.dat

echo "***** changing mumps.dat to read_only *****"
chmod 444 mumps.dat
lsmumps
echo "mupip backup -noonline DEFAULT back.dat"
$MUPIP backup -noonline DEFAULT back.dat
ipcmanage
$gtm_tst/com/dbcheck.csh
\rm -f back.dat
