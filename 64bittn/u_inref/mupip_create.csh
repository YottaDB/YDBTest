#!/usr/local/bin/tcsh -f
# TEST for mupip create
#
# priorver.txt is to filter the old version names in the reference file
echo $v4ver >& priorver.txt
# The test uses aliases sv4 and sv5 to switch versions in GT.M
# These aliases calls switch_gtm_version.csh with "v4ver" or "gtm_test_ver" as arguments for sv4 and sv5 respectively.
#
# yes.txt to be used for user prompts in certification/upgrades.
cp $gtm_tst/$tst/inref/yes.txt .
# check Starting VBN field for both V4 & V5 databases
# switch to V4 version
$sv4
echo "GT.M switched to $v4ver version"
$gtm_tst/com/dbcreate.csh mumps
$DSE change -file -reserved_bytes=8
# certify upgrade the database to V5
$DBCERTIFY scan DEFAULT -outfile=dbcertify_scan.scan
$DBCERTIFY certify dbcertify_scan.scan < yes.txt >>&! dbcertify_scan.out
if ( $status) then
	echo "TEST-E-ERROR. certify failed"
else
	$grep "DBCDBCERTIFIED" dbcertify_scan.out
endif
$MUPIPV5 upgrade mumps.dat < yes.txt
# switch back to V5
$sv5
# convert the gld to V5 format
$GDE exit
#
source $gtm_tst/com/get_dse_df.csh
$grep "Starting VBN" dse_df.log|$tst_awk '{print $7}'
$grep "Master Bitmap Size" dse_df.log|$tst_awk '{print $4}'
if ( (49 != `$grep "Starting VBN" dse_df.log|$tst_awk '{print $7}'`) || (32 != `$grep "Master Bitmap Size" dse_df.log|$tst_awk '{print $4}'`) ) then
	echo "TEST-E-ERROR.Starting VBN / Master Bit map incorrect for $v4ver database"
	cat dse_df.log
else
	echo "PASS for fields Starting VBN & Master Bit Map"
endif
$gtm_tst/com/dbcheck.csh -noonline
mkdir db_backup
mv mumps.gld mumps.dat db_backup
$gtm_tst/com/dbcreate.csh mumps
#
source $gtm_tst/com/get_dse_df.csh "" "newlog"
$grep "Starting VBN" dse_df.log|$tst_awk '{print $7}'
$grep "Master Bitmap Size" dse_df.log|$tst_awk '{print $4}'
if ( (513 != `$grep "Starting VBN" dse_df.log|$tst_awk '{print $7}'`) || (496 != `$grep "Master Bitmap Size" dse_df.log|$tst_awk '{print $4}'`) ) then
	echo "TEST-E-ERROR.Starting VBN / Master bit map incorrect for $tst_ver database"
	cat dse_df.log
else
	echo "PASS for fields Starting VBN & Master Bit Map"
endif
$gtm_tst/com/dbcheck.csh -noonline
