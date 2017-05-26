#!/usr/local/bin/tcsh -f

echo "Begin gtm7082"
setenv gtm_test_jnl "SETJNL"
source $gtm_tst/com/dbcreate.csh mumps

echo "Testing mupip journal -extract=-stdout writes to STDOUT..."
$MUPIP journal -extract=-stdout -forward mumps.mjl

echo "Testing mupip journal -extract=<file> writes to a file..."
$MUPIP journal -extract=mytest.mjf -forward mumps.mjl

echo "Testing mupip journal -extract=-NOSUCHFILE writes to a file named -NOSUCHFILE..."
$MUPIP journal -extract=-NOSUCHFILE -forward mumps.mjl

echo "Testing mupip journal -extract=--forward mumps.mjl gives an error..."
$MUPIP journal -extract=--forward mumps.mjl

echo "Testing mupip journal -extract=-forward mumps.mjl gives an error..."
$MUPIP journal -extract=-forward mumps.mjl

echo "Testing mupip journal -extract= mumps.mjl gives an error..."
$MUPIP journal -extract= mumps.mjl

echo 'Testing mupip set -journal= -reg "*" gives an error...'
$MUPIP set -journal= -reg "*"

diff -- -NOSUCHFILE mytest.mjf

#We have to remove "-NOSUCHFILE" explicitly because test system can't remove this file by itself and issues an error
#Here -- is used to indicate that the desired file starts with a - (See rm manual)
rm -- -NOSUCHFILE
$gtm_tst/com/dbcheck.csh

echo 'Loading stuff to db...'
echo "f i=1:1:32768 s ^x(i)=i,^y(i)=i" | $gtm_exe/mumps -direct

echo 'Creating extracts with "journal -extract=file.txt" and "journal -extract=-stdout > file.txt"'
$MUPIP journal -extract=good_f.txt -detail -forward mumps.mjl
$MUPIP journal -extract=-stdout -detail -forward mumps.mjl > good_s.txt

echo "Comapring good_f.txt and good_s.txt"
diff good_{f,s}.txt

$MUPIP rundown -reg "*" > mumps.txtx
$gtm_tst/com/dbcheck.csh
echo "End gtm7082"
