#!/usr/local/bin/tcsh -f
echo "Test Case: 06 - recov_dbjnlmismatch"
echo "Journal State and journal are modified in database file header before mupip journal command"
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh mumps 1
echo "Start before image journaling"
$MUPIP set -journal=enable,before -reg "*"
$GTM << EOF
f i=1:1:100 s ^val(i)=i
EOF
echo "Save database and journal files"
mkdir ./save
cp {*.mjl*,*.dat} ./save
echo "--------------------------------------------------------------"
echo "mupip journal -show -forward  nonexist.mjl"
$MUPIP journal -show -forward  nonexist.mjl
echo "--------------------------------------------------------------"
echo "mupip journal -recover -forward  nonexist.mjl"
$MUPIP journal -recover -forward  nonexist.mjl
##
echo "--------------------------------------------------------------"
echo "Journal State : OFF"
echo "mupip set -journal=enable,off,file=notexists.mjl -file mumps.dat"
$MUPIP set -journal=enable,off,file=notexist.mjl -file mumps.dat
echo "mupip journal -recover -backward mumps.mjl"
$MUPIP journal -recover -backward mumps.mjl
##
echo "--------------------------------------------------------------"
echo "Journal State : ON"
echo "mupip set -journal=enable,on,before,file=notexists.mjl -file mumps.dat"
$MUPIP set -journal=enable,on,before,file=notexists.mjl -file mumps.dat
echo "mupip journal -recover -backward mumps.mjl"
$MUPIP journal -recover -backward mumps.mjl
echo "--------------------------------------------------------------"
echo "Delete the old database and create a new one"
rm *.dat
$MUPIP create
echo "mupip set -journal=enable,on,before,file=recover.mjl -file mumps.dat"
$MUPIP set -journal=enable,on,before,file=recover.mjl -file mumps.dat
echo "Forward Recover will make journal state OFF"
echo mupip journal -recover -forward mumps.mjl
$MUPIP journal -recover -forward mumps.mjl
echo "Journal state  OFF (expected)"
$DSE dump -f |& $grep "Journal State"
echo "Current Transaction: 0x065 (expected)"
$DSE dump -f |& $grep "Current transaction"
echo "Verify recover.mjl is untouched"
$MUPIP journal -extract -forward -det recover.mjl
##
echo "--------------------------------------------------------------"
echo Jouranl State : DISABLED and with '*' option
cp ./save/*.* .
echo "mupip set -journal=disable -file mumps.dat"
$MUPIP set -journal=disable -file mumps.dat
echo mupip journal -recover -back "*"
$MUPIP journal -recover -back "*"
##
echo "--------------------------------------------------------------"
cp ./save/*.* .
echo Jouranl State : OFF and with '*' option
echo "mupip set -journal=enable,off -file mumps.dat"
$MUPIP set -journal=enable,off -file mumps.dat
echo mupip journal -recover -back "*"
$MUPIP journal -recover -back "*"
##
echo "--------------------------------------------------------------"
cp ./save/*.* .
echo Journal State : ON and with '*' option
echo "mupip set -journal=disable -file mumps.dat"
$MUPIP set -journal=disable -file mumps.dat
echo "mupip set -journal=enable,on,before,file=newa.mjl -file mumps.dat"
$MUPIP set -journal=enable,on,before,file=newa.mjl -file mumps.dat
echo mupip journal -recover -back '"*"'
$MUPIP journal -recover -back "*"
##
echo "--------------------------------------------------------------"
echo Journal State : ON and with nobefore image
cp ./save/*.* .
echo "mupip set -journal=disable -file mumps.dat"
$MUPIP set -journal=disable -file mumps.dat
mv newa.mjl newa_1.mjl	# to avoid FILEEXISTS error in the mupip set journal command
echo "mupip set -journal=enable,on,nobefore,file=newa.mjl -file mumps.dat"
$MUPIP set -journal=enable,on,nobefore,file=newa.mjl -file mumps.dat
echo mupip journal -recover -back mumps.mjl
$MUPIP journal -recover -back mumps.mjl
##
echo "--------------------------------------------------------------"
echo Journal State: OFF and with nobefore image
cp ./save/*.* .
echo "mupip set -journal=disable -file mumps.dat"
$MUPIP set -journal=disable -file mumps.dat
echo "mupip set -journal=enable,off,nobefore,file=newa.mjl -file mumps.dat"
$MUPIP set -journal=enable,off,nobefore,file=newa.mjl -file mumps.dat
echo mupip journal -recover -back mumps.mjl
$MUPIP journal -recover -back mumps.mjl
##
echo "--------------------------------------------------------------"
echo "delete all database and journal files"
rm *.dat *.mjl*
$MUPIP create
echo mupip set -journal=enable,nobefore -reg '"*"'
$MUPIP set -journal=enable,nobefor -reg "*"
echo mupip backup '"*"' backup.dat
$MUPIP backup "*" backup.dat
$GTM << EOF
F i=1:1:100 s ^a(i)="a"_i
h
EOF
rm mumps.dat; cp backup.dat mumps.dat
echo mupip journal -recover -forward mumps.mjl
$MUPIP journal -recover -forward mumps.mjl
echo "Journal State  OFF (expected)"
$DSE dump -f |& $grep "Journal State"
#
echo "--------------------------------------------------------------"
rm *.dat *.mjl*
$MUPIP create
echo mupip set -journal=enable,on,nobefore -file mumps.dat
$MUPIP set -journal=enable,on,nobefore -file mumps.dat
$GTM << EOF
F i=1:1:150 S ^a(i)="a"_i
h
EOF
echo "delete mumps.dat"
rm *.dat
$MUPIP create
echo mupip set -journal=enable,off,before,file=newa.mjl -file mumps.dat
$MUPIP set -journal=enable,off,before,file=newa.mjl -file mumps.dat
echo mupip journal -recover -forward mumps.mjl
$MUPIP journal -recover -forward mumps.mjl
echo "Journal State  OFF (expected)"
$DSE dump -f |& $grep "Journal State"
echo "Current transaction:  x097  (expected)"
$DSE dump -f |& $grep "Current transaction"
#
echo "--------------------------------------------------------------"
rm *.dat *.mjl*
$MUPIP create
echo mupip set -journal=enable,on,nobefore -file mumps.dat
$MUPIP set -journal=enable,on,nobefore -file mumps.dat
$GTM << EOF
F i=1:1:100 S ^a(i)="a"_i
h
EOF
rm *.dat
$MUPIP create
echo mupip set -journal=disable -file mumps.dat
$MUPIP set -journal=disable -file mumps.dat
echo mupip journal -recover -forward mumps.mjl
$MUPIP journal -recover -forward mumps.mjl
echo "Journal State : DISABLED (expected)"
$DSE dump -f |& $grep "Journal State"
echo "Current transaction: 0x065 (expected)"
$DSE dump -f |& $grep "Current transaction"
echo "--------------------------------------------------------------"
#
rm *.dat *.mjl*
$MUPIP create
echo mupip set -journal=enable,before -reg '"*"'
$MUPIP set -journal=enable,nobefor -reg "*"
echo mupip backup '"*"' backup.dat
$MUPIP backup "*" backup.dat
$GTM << EOF
F i=1:1:100 s ^a(i)="a"_i
h
EOF
rm mumps.dat; cp backup.dat mumps.dat
echo mupip journal -recover -forward mumps.mjl
$MUPIP journal -recover -forward mumps.mjl
echo "Journal State  OFF (expected)"
$DSE dump -f |& $grep "Journal State"
echo "Current transaction: 0x065 (expected)"
$DSE dump -f |& $grep "Current transaction"
echo "--------------------------------------------------------------"
$gtm_tst/com/dbcheck.csh
#
mkdir backup
mv *.dat *.mjl* backup
$gtm_tst/com/dbcreate.csh mumps 2
echo mupip set -journal=enable,on,before,file=mumps.mjl -reg DEFAULT
$MUPIP set -journal=enable,on,before,file=mumps.mjl -reg DEFAULT
echo mupip set -journal=enable,on,before,file=a.mjl -reg AREG
$MUPIP set -journal=enable,on,before,file=a.mjl -reg AREG
$GTM << EOF
s ^x=1
s ^a=1
EOF
cp mumps.dat backup_mumps.dat
cp a.dat backup_a.dat
echo mupip set -journal=disable -reg DEFAULT
$MUPIP set -journal=disable -reg DEFAULT
echo mupip journal -recover -back '"*"'
$MUPIP journal -recover -back "*"
echo "--------------------------------------------------------------"
#
cp -f backup_mumps.dat mumps.dat
echo mupip set -journal=enable,off,before -reg AREG
$MUPIP set -journal=enable,off,before -reg AREG
echo mupip journal -recover -back '"*"'
$MUPIP journal -recover -back "*"
echo "--------------------------------------------------------------"
cp -f backup_a.dat a.dat
echo mupip set -journal=enable,on,before,file=a_new.mjl -reg AREG
$MUPIP set -journal=enable,on,before,file=a_new.mjl -reg AREG
echo mupip journal -recover -back mumps.mjl,a.mjl
$MUPIP journal -recover -back mumps.mjl,a.mjl
echo "--------------------------------------------------------------"
cp -f backup_a.dat a.dat
echo mupip set -journal=enable,on,before,file=mupms_new.mjl -reg DEFAULT
$MUPIP set -journal=enable,on,before,file=mumps_new.mjl -reg DEFAULT
echo mupip journal -recover -back mumps.mjl,a.mjl
$MUPIP journal -recover -back mumps.mjl,a.mjl
echo "--------------------------------------------------------------"
echo "End of test"
$gtm_tst/com/dbcheck.csh
