#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Test case 77 : Replication configuration"
unsetenv test_replic
$gtm_tst/com/dbcreate.csh mumps 3
if !(-e mumps.repl)  $MUPIP replic -instance_create -name=$gtm_test_cur_pri_name $gtm_test_qdbrundown_parms
set syslog_time1 = `date +"%b %e %H:%M:%S"`
echo "----------------------------------------------------------------------"
echo "Journal State : a.dat->OFF, b->ON, Replic State: mumps->ON"
echo mupip set -journal=enable,off,nobefore -file a.dat
$MUPIP set -journal=enable,off,nobefore -file a.dat
echo mupip set -journal=enable,on,before -file b.dat
$MUPIP set -journal=enable,on,before -file b.dat
echo mupip set -replication=on -file mumps.dat
$MUPIP  set -replication=on -file mumps.dat
source $gtm_tst/com/portno_acquire.csh >>& portno.out
echo "Now try to start source server  which should error out"
echo $MUPIP replic -source -start -buffsize='$tst_buffsize' -secondary="$tst_now_secondary":'$portno' -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE1
$MUPIP replic -source -start -buffsize=$tst_buffsize -secondary="$tst_now_secondary":"$portno" -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE1
sleep 5 #D9E10-002501 Apparent deadlock b/w source server parent, child and showbacklog commands
$grep "YDB-E-REPLOFFJNLON" SRC_LOG_FILE1
#
echo "----------------------------------------------------------------------"
echo "Journal State : a.dat->OFF, b->OFF, Replic State: mumps->ON"
echo mupip set -journal=enable,off,nobefore -file a.dat
$MUPIP set -journal=enable,off,nobefore -file a.dat
echo mupip set -journal=enable,off,before -file b.dat
$MUPIP set -journal=enable,off,before -file b.dat
echo mupip set -replication=on -file mumps.dat
$MUPIP  set -replication=on -file mumps.dat
echo "Now try to start source server  which should error out"
echo $MUPIP replic -source -start -buffsize='$tst_buffsize' -secondary="$tst_now_secondary":'$portno' -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE2
$MUPIP replic -source -start -buffsize=$tst_buffsize -secondary="$tst_now_secondary":"$portno" -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE2
$grep "YDB-E-REPLOFFJNLON" SRC_LOG_FILE2
#
echo "----------------------------------------------------------------------"
echo "Journal State : a.dat->OFF, b->DISABLED, Replic State: mumps->ON"
echo mupip set -journal=enable,off,nobefore -file a.dat
$MUPIP set -journal=enable,off,nobefore -file a.dat
echo mupip set -journal=disable -file b.dat
$MUPIP set -journal=disable -file b.dat
echo mupip set -replication=on -file mumps.dat
$MUPIP  set -replication=on -file mumps.dat
echo "Now try to start source server  which should error out"
echo $MUPIP replic -source -start -buffsize='$tst_buffsize' -secondary="$tst_now_secondary":'$portno' -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE3
$MUPIP replic -source -start -buffsize=$tst_buffsize -secondary="$tst_now_secondary":"$portno" -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE3
sleep 5 #D9E10-002501 Apparent deadlock b/w source server parent, child and showbacklog commands
$grep "YDB-E-REPLOFFJNLON" SRC_LOG_FILE3
echo "----------------------------------------------------------------------"
echo "Journal State : a.dat->DISABLED, b->OFF, Replic State: mumps->ON"
echo mupip set -journal=disable -file a.dat
$MUPIP set -journal=disable -file a.dat
echo mupip set -journal=enable,off,before -file b.dat
$MUPIP set -journal=enable,off,before -file b.dat
echo mupip set -replication=on -file mumps.dat
$MUPIP  set -replication=on -file mumps.dat
echo "Now try to start source server  which should error out"
echo $MUPIP replic -source -start -buffsize='$tst_buffsize' -secondary="$tst_now_secondary":'$portno' -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE4
$MUPIP replic -source -start -buffsize=$tst_buffsize -secondary="$tst_now_secondary":"$portno" -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE4
sleep 5 #D9E10-002501 Apparent deadlock b/w source server parent, child and showbacklog commands
$grep "YDB-E-REPLOFFJNLON" SRC_LOG_FILE4
echo "----------------------------------------------------------------------"
echo "Journal State : a.dat->DISABLED, b->DISABLED, mumps->DISABLED"
echo mupip set -journal=disable -file a.dat
$MUPIP set -journal=disable -file a.dat
echo mupip set -journal=disable -file b.dat
$MUPIP set -journal=disable -file b.dat
echo mupip set -journal=disable -file mumps.dat
$MUPIP set -journal=disable -replication=off -file mumps.dat
echo "Now try to start source server which should not start"
echo $MUPIP replic -source -start -buffsize='$tst_buffsize' -secondary="$tst_now_secondary":'$portno' -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE5
$MUPIP replic -source -start -buffsize=$tst_buffsize -secondary="$tst_now_secondary":"$portno" -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE5
sleep 5 #D9E10-002501 Apparent deadlock b/w source server parent, child and showbacklog commands
$grep "YDB-W-NOREPLCTDREG" SRC_LOG_FILE5
#####
echo "----------------------------------------------------------------------"
echo "Journal State : a.dat->DISABLED, b->DISABLED, Replic State: mumps->ON"
echo mupip set -journal=disable -file a.dat
$MUPIP set -journal=disable -file a.dat
echo mupip set -journal=disable -file b.dat
$MUPIP set -journal=disable -file b.dat
echo mupip set -replication=on -file mumps.dat
$MUPIP  set -replication=on -file mumps.dat
echo "Now try to start source server  which should should start"
echo $MUPIP replic -source -start -buffsize='$tst_buffsize' -secondary="$tst_now_secondary":'$portno' -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE6
$MUPIP replic -source -start -buffsize=$tst_buffsize -secondary="$tst_now_secondary":"$portno" -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE6
if ($status != 0) then
	cat SRC_LOG_FILE6
endif
sleep 5 #D9E10-002501 Apparent deadlock b/w source server parent, child and showbacklog commands
echo "Shut down the source server"
$MUPIP replicate -source -shutdown -timeout=0 >& shut_down_1.log
if ($status != 0 ) then
	cat shut_down_1.log
endif
#####
echo "----------------------------------------------------------------------"
echo "Journal State : b->DISABLED, Replic State: a->ON,mumps->ON"
echo mupip set -replication=on -file a.dat
$MUPIP set -replicati=on file  a.dat
echo mupip set -journal=disable -file b.dat
$MUPIP set -journal=disable -file b.dat
echo mupip set -replication=on -file mumps.dat
$MUPIP  set -replication=on -file mumps.dat
echo "Now try to start source server  which should start"
echo $MUPIP replic -source -start -buffsize='$tst_buffsize' -secondary="$tst_now_secondary":'$portno' -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE7
$MUPIP replic -source -start -buffsize=$tst_buffsize -secondary="$tst_now_secondary":"$portno" -instsecondary=$gtm_test_cur_sec_name -log=SRC_LOG_FILE7
if ($status != 0) then
	cat SRC_LOG_FILE7
endif
sleep 5 #D9E10-002501 Apparent deadlock b/w source server parent, child and showbacklog commands
echo "Shut down the source server"
$MUPIP replicate -source -shutdown -timeout=0 >& shut_down_2.log
if ($status != 0 ) then
	cat shut_down_2.log
endif
set syslog_time2 = `date +"%b %e %H:%M:%S"`
echo "----------------------------------------------------------------------"
$gtm_tst/com/portno_release.csh
foreach src_log_filename (SRC_LOG_FILE{1,2,3,4,5})
	$gtm_tst/com/getoper.csh "$syslog_time1" "$syslog_time2" syslog1.txt "" "REPLSRCEXITERR.* See log file ${src_log_filename}"
end
echo "######## End of Test #############"
$gtm_tst/com/dbcheck.csh
