#! /usr/local/bin/tcsh -f
echo "Begin of incrgv1 subtest"
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -journal=enable,on,nobefore -reg "*"
$GTM <<\aa
do ^incrgv1
\aa
$MUPIP journal -extract -forward -noverify -fence=none mumps.mjl
$tst_awk -f $gtm_tst/$tst/inref/incrcheckjnlext.awk mumps.mjf
$gtm_tst/com/dbcheck.csh
echo "End  of incrgv1 subtest"
