#!/usr/local/bin/tcsh -f
echo "Test case : 03 -  bij_nodata"
$gtm_tst/com/dbcreate.csh mumps 1
echo "Start before image journaling" 
$MUPIP set -journal="enable,before" -reg "*"
echo "Back up the database"
mkdir ./save; cp *.dat ./save
# with forward option
echo "--------------------------------------------------------"
echo "mupip journal -recover -forward mumps.mjl"
$MUPIP journal -recover -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "--------------------------------------------------------"
rm mumps.dat
# JOURNAL EXTRACT is issued when there are no database files in the current directory.
# JOURNAL EXTRACT might need to read the database file to get the collation information.
# To skip the JOURNAL EXTRACT from reading the database file, set the env variable 
# gtm_extract_nocol to non-zero value.
setenv gtm_extract_nocol 1
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
# with backward option
echo "--------------------------------------------------------"
echo "Copy the  backup database"
cp ./save/*.dat .
echo "mupip journal -recover -backward mumps.mjl"
$MUPIP journal -recover -backward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "--------------------------------------------------------"
rm *.dat
echo "mupip journal -extract -backward mumps.mjl"
$MUPIP journal -extract -backward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "--------------------------------------------------------"
echo "mupip journal -verify -backward mumps.mjl"
$MUPIP journal -verify -backward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "--------------------------------------------------------"
echo "mupip journal -show -backward mumps.mjl"
$MUPIP journal -show -backward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "--------------------------------------------------------"
# all action qualifiers together and forward direction
cp ./save/*.dat .
echo "mupip journal -extract -verify -show -recover -forward mumps.mjl"
$MUPIP journal -extract -verify -show -recover -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "--------------------------------------------------------"
# all action qualifiers together and backward direction
cp ./save/*.dat .
$DSE dump -f |& $grep "Journal State"
echo "mupip journal  -extract -verify -show -recover -backward mumps.mjl"
$MUPIP journal  -extract -verify -show -recover -backward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "===================================================================================="
$gtm_tst/com/dbcheck.csh
