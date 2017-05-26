#! /usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1
echo mupip set -journal="enable,on,before,file=mumps1.mjl" -reg '"*"'
$MUPIP set -journal="enable,on,before,file=mumps1.mjl" -reg "*"
cp mumps.dat backup.dat
$GTM << EOF
s ^x=1
EOF
echo mupip set -journal="enable,on,before,file=mumps2.mjl" -reg '"*"'
$MUPIP set -journal="enable,on,before,file=mumps2.mjl" -reg "*"
$GTM << EOF
s ^y=2
EOF
echo mupip set -journal="enable,on,before,file=mumps3.mjl" -reg '"*"'
$MUPIP set -journal="enable,on,before,file=mumps3.mjl" -reg "*"
$GTM << EOF
s ^z=3
EOF
cp mumps.dat mumpsbak.dat
echo "----------------------------------------------------------------------------"
$DSE change -file -cu=1
echo mupip journal -recover -forward '"*"'
$MUPIP journal -recover -forward "*"
$GTM << EOF
w "^x=",^x,",","^y=",^y,",","^z=",^z,!
EOF
echo "----------------------------------------------------------------------------"
rm mumps.dat
cp  backup.dat mumps.dat
echo mupip journal -recover -forward mumps3.mjl,mumps2.mjl
$MUPIP journal -recover -forward mumps3.mjl,mumps2.mjl
echo "----------------------------------------------------------------------------"
rm mumps.dat
cp -f backup.dat mumps.dat
echo mupip journal -recover -forward mumps3.mjl,mumps1.mjl
$MUPIP journal -recover -forward mumps3.mjl,mumps1.mjl
echo "----------------------------------------------------------------------------"
rm mumps.dat
cp -f backup.dat mumps.dat
echo mupip journal -recover -forward mumps2.mjl,mumps1.mjl
$MUPIP journal -recover -forward mumps2.mjl,mumps1.mjl
$GTM << EOF
w "^x=",^x,",","^y=",^y,",","^z=",^z,!
EOF
echo "----------------------------------------------------------------------------"
rm mumps.dat
cp -f backup.dat mumps.dat
echo mupip journal -recover -forward mumps3.mjl
$MUPIP journal -recover -forward mumps3.mjl
$GTM << EOF
w "^x=",^x,",","^y=",^y,",","^z=",^z,!
EOF
echo "----------------------------------------------------------------------------"
rm mumps.dat
cp -f backup.dat mumps.dat
echo mupip journal -recover -forward -nochain mumps3.mjl
$MUPIP journal -recover -forward -nochain mumps3.mjl
echo "----------------------------------------------------------------------------"
rm mumps.dat
cp -f backup.dat mumps.dat
echo mupip journal -recover -forward -chain mumps2.mjl
$MUPIP journal -recover -forward -chain mumps2.mjl
$GTM << EOF
w "^x=",^x,!
w "^y=",^y,!
w "^z=",^z,!
EOF
echo "----------------------------------------------------------------------------"
rm mumps.dat
cp -f backup.dat mumps.dat
echo mupip journal -recover -forward -nochain -nochecktn mumps3.mjl
$MUPIP journal -recover -forward -nochain -nochecktn mumps3.mjl
$GTM << EOF
w "^z=",^z,!
w "^x=",^x,!
w "^y=",^y,!
EOF
echo "----------------------------------------------------------------------------"
rm mumps.dat
cp -f backup.dat mumps.dat
echo mupip journal -recover -forward -chain mumps3.mjl,mumps1.mjl
$MUPIP journal -recover -forward -chain mumps3.mjl,mumps1.mjl
echo "----------------------------------------------------------------------------"
rm mumps.dat
cp -f backup.dat mumps.dat
echo mupip journal -recover -forward -chain -nochecktn mumps3.mjl,mumps1.mjl
$MUPIP journal -recover -forward -chain -nochecktn mumps3.mjl,mumps1.mjl
$GTM << EOF
w "^x=",^x,!
w "^z=",^z,!
w "^y=",^y,!
EOF
echo "----------------------------------------------------------------------------"
echo "Mutiple generation journal file cannot be specified with backward recovery"
cp -f mumpsbak.dat mumps.dat
echo " mupip journal -recover -backward mumps3.mjl,mumps2.mjl,mumps1.mjl"
$MUPIP  journal -recover -backward mumps3.mjl,mumps2.mjl,mumps1.mjl
echo "End of test"
$gtm_tst/com/dbcheck.csh
