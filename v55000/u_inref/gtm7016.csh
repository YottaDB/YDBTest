#!/usr/local/bin/tcsh -f

echo "Begin gtm7016"
source $gtm_tst/com/dbcreate.csh mumps

echo "Running test.o file to load some variables..."
$gtm_exe/mumps -run gtm7016

echo "Extracting from db to test.glo"
$MUPIP extract test.glo

$MUPIP rundown -reg "*" > mumps.txtx
echo "Moving current db to t1 directory and creating another blank db..."
mkdir t1
mv mumps.* t1
source $gtm_tst/com/dbcreate.csh mumps

echo "Testing mupip load -stdin < test.glo reads from STDIN..."
$MUPIP load -stdin < test.glo
echo "zwrite ^x,^y,^z" | $gtm_exe/mumps -direct
$gtm_tst/com/dbcheck.csh

$MUPIP rundown -reg "*" > mumps.txtx
echo "Moving current db to t2 directory and creating another blank db..."
mkdir t2
mv mumps.* t2
source $gtm_tst/com/dbcreate.csh mumps

echo "Testing mupip load test.glo reads from test.glo..."
$MUPIP load test.glo
echo "zwrite ^x,^y,^z" | $gtm_exe/mumps -direct
$gtm_tst/com/dbcheck.csh

$MUPIP rundown -reg "*" > mumps.txtx
echo "Moving current db to t3 directory and creating another blank db..."
mkdir t3
mv mumps.* t3
source $gtm_tst/com/dbcreate.csh mumps

echo "Testing cat test.glo | mupip load -stdin reads from STDIN..."
cat test.glo | $MUPIP load -stdin
echo "zwrite ^x,^y,^z" | $gtm_exe/mumps -direct
$gtm_tst/com/dbcheck.csh

echo "Testing mupip load -stdin foo.glo < test.glo fails..."
$MUPIP load -stdin foo.glo < test.glo

echo "Testing mupip load -stdin test.glo fails..."
$MUPIP load -stdin test.glo

echo "Testing mupip load test.glo -stdin fails..."
$MUPIP load test.glo -stdin

cp test.glo foo.glo

echo "Testing mupip load test.glo foo.glo fails..."
$MUPIP load test.glo foo.glo

echo "End gtm7016"
