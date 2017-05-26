#!/usr/local/bin/tcsh -f
# dbcertify certify phase (phase-II)
#
cp $gtm_tst/$tst/inref/yes.txt .
echo "dbcertify run without outfile option. should error out"
$DBCERTIFY certify < yes.txt
mkdir tempv5
cp dbcertify_report1.scan ./tempv5
cd tempv5
$sv5
if ($?gt_ld_shl_suffix_saved) then
	cp ../../dbprepare/libreverse${gt_ld_shl_suffix_saved} .
endif
$gtm_tst/com/dbcreate.csh mumps
#
$sv4
cp -f ../mumps.gld .
echo "version switched to is "$v4ver
echo "dbcertify attempted on a V5 database. should issue BADDBVER error"
$DBCERTIFY certify dbcertify_report1.scan < ../yes.txt >&! baddbver.out
if ( $status == 0 ) then
	echo "TEST-E-ERROR certification expected to fail on V5 db but passed"
	cat baddbver.out
else
	grep "BADDBVER" baddbver.out
	echo "PASS, expected error received"
endif
rm -f baddbver.out
cd ../
rm -rf tempv5
#
echo "dbcertify used with report_only option for certify phase. should issue CLIERR error"
$DBCERTIFY -report_only certify dbcertify_report1.scan < yes.txt
#
($gtm_exe/mumps -run ^onlnread < /dev/null >>& onlnread_certphase.out &) >&! bgid1.out
$gtm_tst/$tst/u_inref/wait_for_onlnread_to_start.csh 60
echo "dbcertify attempted when a concurrent GT.M process is running. should issue MUSTANDALONE error"
$DBCERTIFY certify dbcertify_report1.scan < yes.txt
$GTM << gtm_eof
set ^stop=1
halt
gtm_eof
#
set pid = `cat concurrent_job.out`
$gtm_tst/com/wait_for_proc_to_die.csh $pid -1
rm -f concurrent_job.out
if (`grep -v "PASS" onlnread_certphase.out|wc -l`) then
        echo "TEST-E-ERROR Verification failed for GT & DT.Pls. check onlnread.out"
endif
#
echo "dbcertify run with an improper report file. should issue DBCBADFILE error"
$DBCERTIFY certify mumps.dat < yes.txt
mv mumps.dat x.dat
cp x.dat mumps.dat
echo "dbcertify run on a database which is moved/renamed after the report file creation. should issue DBCNOTSAMEDB error"
$DBCERTIFY certify dbcertify_report1.scan < yes.txt
#
$DSE change -file -reserved_bytes=0 -record_max_size=496
$GTM << gtm_eof
for i=1:1:100000 set ^a(i)=i
halt
gtm_eof
$DSE change -file -reserved_bytes=8
# at this point after setting too-big blocks try out scan phase
echo "dbcertify scan run. should pass"
$DBCERTIFY scan -outfile=dbcertify_report3.scan DEFAULT
$DSE change -fileheader -reserved_bytes=0
# run the same too-big blocks loop
$GTM << gtm_eof
for i=1:1:100000 set ^a(i)=i
halt
gtm_eof
$DSE change -fileheader -reserved_bytes=8
echo "dbcertify run with too big records. should issue DBCMODBLK2BIG error"
$DBCERTIFY certify dbcertify_report3.scan < yes.txt >>&! dbcertify_report3.out
grep "DBCMODBLK2BIG" dbcertify_report3.out
rm -f mumps.dat
mv x.dat mumps.dat
#
$DSE change -fileheader -kill=1
echo "dbcertify run on a database which has non-zero kill-in-progress value. should issue DBCKIIIP error"
$DBCERTIFY certify dbcertify_report1.scan < yes.txt
#
$DSE change -fileheader -kill=0
$DSE dump -file|& $tst_awk ' /Extension Count/ {print $7}'| $tst_awk '{if (100 !~ $0) print "TEST-E-ERROR.Extension count expected is 100 but has "$0""}'
#
if (! $?jnl_rand) then
	@ jnl_rand_temp=`$gtm_exe/mumps -run rand 100`
	@ jnl_rand = $jnl_rand_temp + 1
endif
echo "setenv jnl_rand $jnl_rand" >>! settings.csh
$MUPIP set -exten=$jnl_rand -file mumps.dat
if ( $jnl_rand < 25) then
        $MUPIP set -journal="enable,off,nobefore" -file mumps.dat >>&! jnl_rand.log
else if ( $jnl_rand  > 25 && $jnl_rand < 50) then
        $MUPIP set -journal="enable,on,nobefore" -file mumps.dat >>&! jnl_rand.log
else if ( $jnl_rand  > 50 && $jnl_rand < 75) then
        $MUPIP set -journal="enable,on,before" -file mumps.dat >>&! jnl_rand.log
else
        $MUPIP set -journal="enable,on,before" -replication=on -file mumps.dat >>&! jnl_rand.log
endif
# check od output of the file header to ensure certified bit as 0
## check for "Certified for DB format" field from dse output
$DSE change -fileheader -hexloc=13F8 -size=4 | & $tst_awk ' /New Value / {print $8}' | $tst_awk '{if (0 !~ $0) print "TEST-E-ERROR.Certfied bit expected as 0 but got "$0""}'
#
echo "dbcertify should run fine without errors here,should issue DBCDBCERTIFIED message"
$DBCERTIFY certify -debug dbcertify_report1.scan < yes.txt >>&! dbcertify_report1.out
# Check the status of it and exit if failed.
$grep "DBCDBCERTIFIED" dbcertify_report1.out
if ($status) then
	echo "TEST-E-DBCERTIFY failed. The test will exit now"
	exit 1
endif

$DSE dump -file|& $tst_awk ' /Journal State/ || / Journaling/{if( ($3 == "OFF") || ($5 == "OFF") ) print "Journal state PASS after certifying phase";else print "TEST-E-ERROR.JournalState expected OFF but got "$3" and " $5""}'
$DSE dump -file|& $tst_awk ' /Replication State/ {print $3}'| $tst_awk '{if (("OFF" !~ $0) && ("CLOSED" !~ $0)) print "TEST-E-ERROR.Replication State expected OFF but got "$0"";else print "Replication state PASS after certifying phase"}'
#
echo "dbcertify scan should run fine here without errors"
$DBCERTIFY scan -report_only DEFAULT
$DBCERTIFY scan -report_only DEFAULT|$grep -E "DT|GVT " | sed 's/^.*-//g' | sed 's/ *//g' | sed 's/\t*//g' | $tst_awk -F"[" '{print $1}' >& zerochk.out
if (`grep -v "^0" zerochk.out|wc -l`) then
        echo "TEST-E-ERROR DVT or GT has NON-ZERO value in them. Pls. check dbceritfy scan results"
else
	echo "DVT,GT check PASSED"
endif
$gtm_tst/com/dbcheck.csh
$gtm_exe/mumps -run verify^upgrdtst
# check again the od output of the file header to ensure certified bit as 1
$DSE change -fileheader -hexloc=13F8 -size=4 | & $tst_awk ' /New Value / {print $8}' | $tst_awk '{if (1 !~ $0) print "TEST-E-ERROR.Certfied bit expected as 1 but got "$0"";else print "Correct value set for Certified bit"}'
echo "setting globals.should run fine"
$GTM << gtm_eof
set type="dirtrand1",num=10000
do setdirt^upgrdtst
set type="gvtrand1",num=50000
do setgvt^upgrdtst
halt
gtm_eof
# since expected errors from the above steps will get finally displayed in the outfile we
# zip those elements
$tst_gzip dbcertify_report3.out
