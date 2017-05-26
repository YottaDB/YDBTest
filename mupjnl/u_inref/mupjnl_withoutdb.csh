#!/usr/local/bin/tcsh -f
echo "Test case : 05 - mupjnl_withoutdb"
echo "recover needs database access, while extract/show/verify do not need database access" 
$gtm_tst/com/dbcreate.csh mumps 1
cp mumps.dat back1.dat
echo "Start before image journaling"
$MUPIP set -journal=enable,before -reg "*"
$GTM << EOF
f i=1:1:100 s ^val(i)=i
EOF
cp mumps.dat back2.dat
echo "delete  database"
rm mumps.dat
echo "------------------------------------------------------------------"
echo "mupip journal -recover -extract -verify -show -forward  mumps.mjl"
$MUPIP journal -recover -extract -verify -show -forward  mumps.mjl
echo "------------------------------------------------------------------"
echo "mupip journal -recover -extract -verify -show -backward  mumps.mjl"
$MUPIP journal -recover -extract -verify -show -backward  mumps.mjl
echo "------------------------------------------------------------------"
# JOURNAL EXTRACT is issued when there are no database files in the current directory.
# JOURNAL EXTRACT might need to read the database file to get the collation information.
# To skip the JOURNAL EXTRACT from reading the database file, set the env variable 
# gtm_extract_nocol to non-zero value.
setenv gtm_extract_nocol 1
echo "mupip journal -extract -verify -show -forward  mumps.mjl"
$MUPIP journal -extract -verify -show -forward  mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "------------------------------------------------------------------"
echo "mupip journal -extract -verify -show -backward  mumps.mjl"
$MUPIP journal -extract -verify -show -backward  mumps.mjl
unsetenv gtm_extract_nocol
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "------------------------------------------------------------------"
echo "cp -f back1.dat mumps.dat"
cp -f back1.dat mumps.dat
echo "mupip journal -recover -extract -verify -show -forward  mumps.mjl"
$MUPIP journal -recover -extract -verify -show -forward  mumps.mjl
echo "------------------------------------------------------------------"
echo "cp -f back2.dat mumps.dat"
cp -f back2.dat mumps.dat
echo "mupip journal -recover -extract -verify -show -backward  mumps.mjl"
$MUPIP journal -recover -extract -verify -show -backward  mumps.mjl
echo "------------------------------------------------------------------"
echo "End of test"
$gtm_tst/com/dbcheck.csh
