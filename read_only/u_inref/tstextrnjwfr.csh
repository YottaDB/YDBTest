#! /usr/local/bin/tcsh -f
#Tests of mupip command "EXTRACT" with no journal with freeze
echo ""
echo "*** TSTEXTRNJ.CSH ***"
echo ""

# dbcreate.csh not used because we re-use part of what was created in tstcreate.csh
$MUPIP create
chmod 666 mumps.dat
lsmumps

setenv GTM "$gtm_exe/mumps -direct"

$GTM<<aaa
w "do init",!  d ^init
aaa

echo "mupip extract -fr -nolog glo.dir"
$MUPIP extract -fr -nolog glo.dir
ipcmanage
$gtm_tst/com/dbcheck.csh

echo "***** changing mumps.dat to read_only *****"
chmod 444 mumps.dat
lsmumps
/bin/rm -f glo.dir
echo "mupip extract -fr -nolog glo.dir"
$MUPIP extract -fr -nolog glo.dir
ipcmanage
$gtm_tst/com/dbcheck.csh

/bin/rm -f mumps.dat glo.dir
