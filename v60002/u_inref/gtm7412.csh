#!/usr/local/bin/tcsh -f
echo "# Begin gtm7412 - check operator log for warnings when database extension=0"
# Get a random allocation value, between 100 and 20000
set alloc = `$gtm_exe/mumps -run rand 19100 1 100`
echo "# GTM_TEST_DEBUGINFO allocation : " $alloc

# Create database
$gtm_tst/com/dbcreate.csh mumps -allocation=$alloc -record=1010
$MUPIP set -exten=0 -region DEFAULT
set syslog_before1 = `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run %XCMD 'for i=1:1 set ^a(i)=$justify(i,900)'
sleep 1		# to ensure getoper has a working window
set syslog_after1 = `date +"%b %e %H:%M:%S"`
echo $syslog_before1 $syslog_after1 > time_window1.txt
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt "" "GTM-E-GBLOFLOW"
$gtm_tst/com/grepfile.csh "GTM-W-FREEBLKSLOW" syslog1.txt 1
$gtm_tst/com/dbcheck.csh
echo "# End gtm7412"
