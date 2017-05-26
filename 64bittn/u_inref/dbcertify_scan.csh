#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# dbcertify scan phase (phase-I)
#
#### This section checks dbcertify works only with V4 database ####
$gtm_tst/com/dbcreate.csh mumps
$MUPIP set -reserved_bytes=8 -reg DEFAULT
echo "dbcertify scan run on V5 database,should issue BADDBVER error"
$DBCERTIFY scan -report_only DEFAULT
echo "dbcertify scan run on V5 database,should issue BADDBVER error"
$DBCERTIFY scan DEFAULT
#### This section checks for various errors reported by dbcertify on a random V4 version ####
rm -f mumps.dat mumps.gld
$sv4
echo "version switched to is "$v4ver
# priorver.txt is to filter the old version names in the reference file
echo $v4ver >& priorver.txt
# make use of the too-full blocks database already created
source $gtm_tst/$tst/u_inref/v4dat.csh
$MUPIP set -reserved_bytes=8 -reg DEFAULT
#onlnread.m should be running concurrently from here till the end of this test & hence pushed to the background
($gtm_exe/mumps -run ^onlnread < /dev/null >>& onlnread_scanphase.out&) >&! bgid.out
$gtm_tst/$tst/u_inref/wait_for_onlnread_to_start.csh 60
$DSE change -fileheader -reserved_bytes=7
echo "dbcertify scan run on V4 database with <8 reserved bytes,should issue DBMINRESBYTES error"
$DBCERTIFY scan DEFAULT
$DSE change -fileheader -reserved_bytes=8
$DSE change -fileheader -record_max_size=497
#
echo "dbcertify scan run on V4 database with max_record_size is > (db_block_size - 16) ,should issue DBMAXREC2BIG error"
$DBCERTIFY scan DEFAULT
$DSE change -fileheader -reserved_bytes=0 -record_max_size=504
#
echo "dbcertify scan run with report_only & outfile options.Should pass and not error out"
echo "check for reserved bytes and record_max_size complaints from the scan run"
$DBCERTIFY scan -report_only -outfile=dbcertify_report1.scan DEFAULT
ls mumps.dbcertscan >& /dev/null
if ($status == 0) then
        echo "TEST-E-ERROR dbcertify not expected to create mumps.dbcertscan file,but has"
else
	echo "PASS scan report not created"
endif
echo "dbcertify scan run with just report_only option,should pass"
$DBCERTIFY scan -report_only DEFAULT >>&! dbcertify_output1.out
ls mumps.dbcertscan >& /dev/null
if ($status == 0) then
        echo "TEST-E-ERROR dbcertify not expected to create mumps.dbcertscan file,but has"
else
	echo "PASS scan report not created"
endif
$GTM << gtm_eof
do setbig^upgrdtst
halt
gtm_eof
echo "dbcertify scan run with too-big records. should NOT issue DBCREC2BIG but only DBMAXREC2BIG"
$DBCERTIFY scan -report_only DEFAULT >>&! dbcertify_output2.out
if ($status) then
        echo "TEST-E-ERROR. Exit status not normal"
endif
diff dbcertify_output1.out dbcertify_output2.out >& /dev/null
if  ($status) then
        echo "Displaying dbcertify_output2.out in the reference file"
else
        echo "TEST-E-ERROR. difference in scan outfiles expected but not found"
endif
cat dbcertify_output2.out
rm -f dbcertify_output1.out dbcertify_output2.out
$DSE change -fileheader -reserved_bytes=8 -record_max_size=496
#
echo "dbcertify scan run with too-long records .should issue DBCREC2BIG error"
$DBCERTIFY scan -outfile=dbcertify_report1.scan DEFAULT >>&! scan_recbig.log
# this is done to avoid reference file issues
$grep "DBCREC2BIG" scan_recbig.log | $head -n 1
ls dbcertify_report1.scan >& /dev/null
if ($status == 0) then
        echo "TEST-E-ERROR dbcertify has created dbcertify_report1.scan inspite of error"
endif
# kill too-long records previosuly set
$GTM << gtm_eof
do killbig^upgrdtst
halt
gtm_eof
echo "dbceritfy scan should run fine here"
$MUPIP backup DEFAULT pre_scan_mumps.dat >& pre_scan_backup.out	# Take backup of mumps.dat before dbcertify scan; Needed by dbcertify_certify.csh
$DBCERTIFY scan -outfile=dbcertify_report1.scan DEFAULT
ls dbcertify_report1.scan >& /dev/null
if ($status) then
        echo "TEST-E-ERROR dbcertify didn't create the outfile expected"
endif
# ^stop=1 ensures concurrently running onlnread.m stops
$GTM << gtm_eof
set ^stop=1
halt
gtm_eof
set pid = `cat concurrent_job.out`
$gtm_tst/com/wait_for_proc_to_die.csh $pid -1
rm -f concurrent_job.out
if (`$grep -v "PASS" onlnread_scanphase.out | $grep -i "[a-z]"|wc -l`) then
        echo "TEST-E-ERROR Verification failed for GT & DT.Pls. check onlnread_scanphase.out"
else
	echo ""
	echo "dbcertify scan phase PASSED, database & report file are preserved to be used for  certify phase"
	echo ""
endif
mv mumps.dat mumps_bak.dat
mv mumps.gld mumps_bak.gld
# for changing the compression count temporarily copy the database
cp mumps_bak.dat mumps.dat
cp mumps_bak.gld mumps.gld
# create a compression count warning and check scan results
$DSE CHANGE -BLOCK=3 -REC=1 -CMPC=1
#
echo "dbcertify scan run with CMPC warning. should not issue DBCINTEGERR error"
$DBCERTIFY scan DEFAULT
if ($status) then
	echo "TEST-E-ERROR DBCINTEGERR not expected"
else
	echo "PASS no error detected"
endif
set savedist=`echo $gtm_dist`
setenv gtm_dist 'DUMMY'
echo "dbcertify scan run with incorrect gtm_dist value. should issue DBCCMDFAIL error"
$DBCERTIFY scan DEFAULT
setenv gtm_dist $savedist
# restore original database
mv mumps_bak.dat mumps.dat
mv mumps_bak.gld mumps.gld
#
$tst_gzip scan_recbig.log
$gtm_tst/com/dbcheck.csh
