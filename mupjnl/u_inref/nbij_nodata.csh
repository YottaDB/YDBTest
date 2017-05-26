#!/usr/local/bin/tcsh -f
echo "Test case : 01 - nbij_nodata"
$gtm_tst/com/dbcreate.csh mumps 1
echo MUPIP set -journal="enable,nobefore" -reg '"*"'
$MUPIP set -journal="enable,nobefore" -reg "*"
mkdir ./save; cp *.dat ./save
echo "rm mumps.dat"
rm mumps.dat
echo MUPIP create
$MUPIP  create
# with forward option
echo "With  -forward option"
echo "mupip journal -recover -forward mumps.mjl"
$MUPIP journal -recover -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "--------------------------------------------------------"
echo "mupip journal -extract -forward mumps.mjl"
$MUPIP journal -extract -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "--------------------------------------------------------"
echo "mupip journal -verify -forward mumps.mjl"
$MUPIP journal -verify -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "--------------------------------------------------------"
echo "mupip journal -show -forward mumps.mjl"
$MUPIP journal -show -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "--------------------------------------------------------"
# all action qualifiers together and forward direction
echo "mupip journal -extract -verify -show -recover -forward mumps.mjl"
$MUPIP journal -extract -verify -show -recover -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "==========================================================="
# with backward option
echo "With  backard option: all should fail because of NBIJ"
echo "Copy backup databases"
cp -f ./save/*.dat .
echo "mupip journal -recover -backward mumps.mjl"
$MUPIP journal -recover -backward mumps.mjl
echo "--------------------------------------------------------"
cp -f ./save/*.dat .
echo "mupip journal -extract -backward mumps.mjl"
$MUPIP journal -extract -backward mumps.mjl
echo "--------------------------------------------------------"
echo "mupip journal -verify -backward mumps.mjl"
$MUPIP journal -verify -backward mumps.mjl
echo "--------------------------------------------------------"
echo "mupip journal -show -backward mumps.mjl"
$MUPIP journal -show -backward mumps.mjl
echo "--------------------------------------------------------"
# all action qualifiers together and backward direction
echo "mupip journal  -extract -verify -show -recover -backward mumps.mjl"
$MUPIP journal  -extract -verify -show -recover -backward mumps.mjl
echo "===================================================================================="
touch dont_mask_jnleod.txt # Tells outstream.awk to skip masking 'End of Data' field of journal file header #BYPASSOK
$gtm_tst/com/dbcheck.csh
