#!/usr/local/bin/tcsh -f
#
# D9I07002691 : accept decimal values in ZWR loads
#
$gtm_tst/com/dbcreate.csh mumps 1

echo "# load some interesting values and save them in zwr format"
$GTM << GTM_EOF
set ^a=1
set ^a(.1)=1
set ^a(1)=.1
set ^a(2)=1.1
do ^%GO
a

D9I07002691
ZWR
d9I07002691.zwr
GTM_EOF

echo "# mess up the last record to test that load detects the error"
cp d9I07002691.zwr d9I07002691.bak
$tst_awk -F = '{if ($NF == "1.1") {sub("1.1","1.1.1")} print}' d9I07002691.bak > d9I07002691.zwr

echo "# Run the MUPIP LOAD"
$gtm_exe/mupip load -format=zwr d9I07002691.zwr

$gtm_tst/com/dbcheck.csh
echo "End of D9I07002691 test..."
