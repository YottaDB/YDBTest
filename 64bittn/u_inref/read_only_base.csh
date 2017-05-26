#! /usr/local/bin/tcsh -f
# switch to v4 databases
$sv4
source $gtm_tst/$tst/u_inref/v4dat.csh
$DSE  change -file -reserve=8
echo "make database read-only"
chmod -w mumps.dat
echo "make current directory read-only"
chmod -w  .
echo "should issue DEVOPENFAIL error accompanied with TEXT message indicating permission issue"
$DBCERTIFY SCAN -outfile=dbcertify_report1.txt DEFAULT
echo  "current directory back to read-write"
chmod +w .
echo "should issue DBRDONLY error"
$DBCERTIFY scan -outfile=dbcertify_report1.txt DEFAULT
echo "make database back to read-write"
chmod +w  mumps.dat
echo "scan should run fine here"
$DBCERTIFY scan -outfile=dbcertify_report1.txt DEFAULT
echo "make database read-only again"
chmod -w  mumps.dat
echo "should issue DBRDONLY error"
$DBCERTIFY certify dbcertify_report1.txt < $gtm_tst/$tst/inref/yes.txt
echo "Now make db read_write"
chmod +w  mumps.dat
echo "run dbcertify again,should be fine here"
$DBCERTIFY certify dbcertify_report1.txt < $gtm_tst/$tst/inref/yes.txt >& certify.out
$grep "DBCDBCERTIFIED" certify.out
# take a copy of v4 gld to be used down the line
cp mumps.gld mumps_v4.gld
echo "Before switching to version V5, make database read-only again"
chmod -w mumps.dat
echo "Switch to V5 version"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "############## UPGRADE #################"
echo "Upgrade global directory"
$GDE exit
echo "should issue DBRDONLY error"
$MUPIP upgrade mumps.dat < $gtm_tst/$tst/inref/yes.txt
echo "======= successful upgrade ======="
chmod +w mumps.dat
$MUPIP upgrade mumps.dat < $gtm_tst/$tst/inref/yes.txt
echo "############## DOWNGRADE #################"
echo " Try to downgrade"
chmod -w mumps.dat
echo "should issue DBRDONLY error"
$MUPIP downgrade mumps.dat < $gtm_tst/$tst/inref/yes.txt
echo "==== successful downgrade ========"
chmod +w mumps.dat
$MUPIP downgrade mumps.dat < $gtm_tst/$tst/inref/yes.txt
echo "run db certification phases and do a mupip upgrade on the downgraded db.All steps should pass"
# switch to v4 version
$sv4
cp -f mumps_v4.gld mumps.gld
$DBCERTIFY scan DEFAULT
$DBCERTIFY certify mumps.dat.dbcertscan < $gtm_tst/$tst/inref/yes.txt >& certify_2.out
$grep "DBCDBCERTIFIED" certify_2.out
$sv5
$GDE exit
$MUPIP upgrade mumps.dat < $gtm_tst/$tst/inref/yes.txt
chmod -w mumps.dat
echo "All of the following commands from now on should give DBRDONLY error"
echo "===== version ======="
echo "MUPIP SET -VERSION=V6 -reg DEFAULT"
$MUPIP SET -VERSION=V6 -reg DEFAULT
echo "MUPIP SET -VERSION=V4 -reg DEFAULT"
$MUPIP SET -VERSION=V4 -reg DEFAULT
echo "====== access_method ======="
# access method changes on a read-only database currently gives only "permission denied" error message
# pls. fix the reference file to include DBRDONLY when the software is corrected
$MUPIP SET -ACCESS_METHOD=BG -file mumps.dat
$MUPIP SET -ACCESS_METHOD=MM -file mumps.dat
echo "==== REORG upgrade ===="
$MUPIP REORG -upgrade -SAFEJNL -reg DEFAULT
echo "==== REORG downgrade ===="
$MUPIP REORG -downgrade -SAFEJNL -reg DEFAULT
echo "== Make database read-write before final verification ==="
chmod +w mumps.dat
echo "Final verification for upddated database should run fine"
$GTM << aa
do verify^upgrdtst
aa
#
