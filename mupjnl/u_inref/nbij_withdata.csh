#!/usr/local/bin/tcsh -f
echo "Test case :  02 - nbij_withdata"
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -journal=enable,nobefore -reg "*"
echo "save the database"
mkdir ./save; cp *.dat ./save
echo "Do some updates"
$GTM << GTM_EOF_1
f i=1:1:100 s ^val(i)=i
GTM_EOF_1
echo "delete the database"
rm mumps.dat
echo "MUPIP create"
$MUPIP create
#with forward direction
echo "-----------------------------------------------------------"
echo "mupip journal -recover -forward mumps.mjl"
$MUPIP journal -recover -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
$GTM << GTM_EOF_2
 w "data verification",!
 d ^test02
GTM_EOF_2
echo "-----------------------------------------------------------"
echo "mupip journal -extract -forward mumps.mjl"
$MUPIP journal -extract -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
#find . -name "mumps.mjf" 
#if ($status == 0) then
#	echo "PASSED"
#else
#	echo "FAILED"
#endif
echo "-----------------------------------------------------------"
echo "mupip journal -verify -forward mumps.mjl"
$MUPIP journal -verify -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "-----------------------------------------------------------"
echo "mupip journal -show -forward mumps.mjl"
$MUPIP  journal -show -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "-----------------------------------------------------------"
# with backward option
echo "With backward option; all should fail"
echo "Copy backup database"
cp -f ./save/*.dat . 
$DSE dump -f |& grep "Journal State"
echo "mupip journal -recover -backward mumps.mjl"
$MUPIP journal -recover -backward mumps.mjl
echo "-----------------------------------------------------------"
cp -f ./save/*.dat . 
echo "mupip journal -extract -backward mumps.mjl"
$MUPIP journal -extract -backward mumps.mjl
echo "-----------------------------------------------------------"
echo "mupip journal -verify -backward mumps.mjl"
$MUPIP journal -verify -backward mumps.mjl
echo "-----------------------------------------------------------"
# all action qualifiers together and backward option
echo "mupip journal -extract -verify -recover -show -backward mumps.mjl"
$MUPIP journal -extract -verify -recover -show -backward mumps.mjl
echo "-----------------------------------------------------------"
# all action qualifiers together and forward option
cp ./save/*.dat . 
echo "mupip journal -extract -verify -recover -show  -forward mumps.mjl"
$MUPIP journal -extract -verify -recover -show  -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "-----------------------------------------------------------"
#cp -f ./save/*.dat .
mkdir ./save1
mv *.dat ./save1; mv *.mjl* ./save1
$MUPIP create
#cp mumps.dat bakmumps.dat
$MUPIP set -journal=enable,nobefore -file mumps.dat
$GTM << aa
s ^x=1
aa
echo "mupip journal -extract -forward -det mumps.mjl"
$MUPIP journal -extract -forward -det mumps.mjl
$tst_awk -F "\\" '$1 ~ /SET/ {print $NF}' mumps.mjf
##
$GTM <<aa
zsy "$DSE buff"
h 2
zsy "$gtm_tst/com/abs_time.csh time1.txt"
h 2
s ^x=2
aa
set time1 = `cat time1.txt_abs`
echo 'mupip journal -extract=ll.mjf -forward -after=\"$time1\" -before=\"$time1\" mumps.mjl'
$MUPIP journal -extract=ll.mjf -forward -after=\"$time1\" -before=\"$time1\" mumps.mjl
#
$gtm_tst/com/dbcheck.csh
echo "End of  test -02"
