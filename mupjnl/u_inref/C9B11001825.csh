#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore 
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh . 3
$gtm_tst/com/jnl_on.csh

$GTM << gtm_eof
zts
s ^xx=1
h 1
s ^ax=1
h 1
s ^bx=1
h 1
gtm_eof
$gtm_tst/$tst/u_inref/C9C05001997.csh

set echo
set verbose
$MUPIP set -journal="on,enable,before,file=a1.mjl" -file a.dat
$MUPIP set -journal="on,enable,before,file=b1.mjl" -file b.dat
$MUPIP set -journal="on,enable,before,file=mumps1.mjl" -file mumps.dat
unset echo
unset verbose

$gtm_tst/com/abs_time.csh time0
$GTM << gtm_eof
zts
s ^xx=1
s ^ax=1
s ^bx=1
h 1
gtm_eof
$gtm_tst/com/abs_time.csh time1
sleep 1

#$MUPIP set -journal="on,enable,before,file=mumps2.mjl" -reg "*"
$MUPIP set -journal="on,enable,before,file=a2.mjl" -file a.dat
$MUPIP set -journal="on,enable,before,file=b2.mjl" -file b.dat
$MUPIP set -journal="on,enable,before,file=mumps2.mjl" -file mumps.dat

$GTM << gtm_eof
s ^ay=2
s ^by=2
s ^xy=2
gtm_eof

set time0 = `cat time0_abs`
set time1 = `cat time1_abs`
set echo
set verbose
#a) Test that backward recovery checks journal file name in database file header.
$MUPIP journal -recov -back mumps1.mjl -extract=1.mjf
#Expected result: journal file name does not match database file header.
#Return Status: GTM-E-JNLNMBKNOTPRCD
#whereas the following should work:
$MUPIP journal -recov -back mumps2.mjl -extract=2.mjf

#b) Test that backward recovery does not allow more than one-generation journal
#file per region to be specified explicitly in the command line.

$MUPIP journal -recov -back mumps1.mjl,mumps2.mjl -since=\"$time1\" -extract=3.mjf
#Expected result: Only one-generation journal file per region can be specified explicitly
#Return status: GTM-E-JNLNMBKNOTPRCD
###
cp mumps2.mjl mumpsn.mjl
$MUPIP journal -recov -back mumps2.mjl,mumpsn.mjl -since=\"$time1\" -extract=3n.mjf
$MUPIP journal -recov -back mumpsn.mjl -since=\"$time1\" -extract=3n.mjf
###


rm a1.mjl
$MUPIP journal -recov -back mumps2.mjl,a2.mjl -since=\"$time0\" -extract=4.mjf >& mupip_journal_recov_back.outx
grep -v MUJNLPREVGEN mupip_journal_recov_back.outx

$MUPIP set -journal="on,enable,before,file=a3.mjl" -file a.dat
$MUPIP set -journal="on,enable,before,file=b3.mjl" -file b.dat
$MUPIP set -journal="on,enable,before,file=mumps3.mjl" -file mumps.dat

$MUPIP journal -recov -back mumps2.mjl -since=\"$time1\" -extract=5.mjf

$GTM << gtm_eof
s ^az=3
s ^bz=3
s ^xz=3
gtm_eof

$MUPIP journal -recov -back mumps1.mjl,mumps2.mjl,mumps3.mjl -extract=7.mjf
$MUPIP journal -recov -back mumps1.mjl,mumps3.mjl -extract=8.mjf

rm mumps2.mjl
$MUPIP journal -recov -back mumps3.mjl -since=\"$time1\" -extract=9.mjf
$MUPIP journal -recov -back mumps2.mjl,mumps1.mjl -since=\"$time1\" -extract=10.mjf
$MUPIP journal -recov -back mumps2.mjl -since=\"$time1\" -extract=11.mjf
$MUPIP journal -recov -back mumps2.mjl,a3.mjl -since=\"$time1\" -extract=12.mjf

$gtm_tst/com/dbcheck.csh
