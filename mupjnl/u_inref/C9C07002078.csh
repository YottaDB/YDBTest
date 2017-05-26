#! /usr/local/bin/tcsh -f
echo "Test  case : 31- C9C07-2078"
echo "C9C07-002078 - ZTCOMMIT record should keep exact number of regions participated in it"
$gtm_tst/com/dbcreate.csh mumps 3
echo mupip set -journal="enable,before" -reg '"*"'
$MUPIP set -journal="enable,before" -reg "*" |& sort -f 
echo mumps -run c2078
$gtm_exe/mumps -run c2078
set time1 = `cat time1.txt_abs`
echo mupip journal -recover -back -since=\"time1\" -look=\"time=0 00:00:00\" a.mjl
$MUPIP journal -recover -back -since=\"$time1\" -look=\"time=0 00:00:00\" a.mjl
$gtm_tst/com/dbcheck.csh
