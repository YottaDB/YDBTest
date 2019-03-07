#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that process-type(SRC, RCV, UPD or HELPER) are part of facility for operator log messages when replication is on and
# Source,Receiver server or Update process or Helper processes are running.

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 67	# WBTEST_OPER_LOG_MSG
$MULTISITE_REPLIC_PREPARE 2
setenv gtm_test_mupip_set_version "disable"
#create database with one region
$gtm_tst/com/dbcreate.csh mumps

set syslog_before = `date +"%b %e %H:%M:%S"`
echo "syslog_before=$syslog_before" >&! syslog_time.outx
$MSR START INST1 INST2
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP  replicate -receive -start -helpers >& helpers_start.out'
$GTM <<  ENDEOF
for i=0:1:1000 set ^x(i)=\$j(" ",200)
ENDEOF
$MSR SYNC INST1 INST2
set syslog_after = `date +"%b %e %H:%M:%S"`
echo "syslog_after=$syslog_after" >>&! syslog_time.outx

foreach proc_type ("SRCSRVR" "RCVSRVR" "UPDPROC" "UPDREAD" "UPDWRITE")
	switch ( $proc_type )
		case "SRCSRVR":
			setenv msg "YDB\-${proc_type}\-INSTANCE1"
			breaksw
		case "RCVSRVR":
			setenv msg "YDB\-${proc_type}\-INSTANCE2"
			breaksw
		case "UPDPROC"
			setenv msg "YDB\-${proc_type}\-INSTANCE2"
			breaksw
		case "UPDREAD"
			setenv msg "YDB\-${proc_type}\-INSTANCE2"
			breaksw
		case "UPDWRITE"
			setenv msg "YDB\-${proc_type}\-INSTANCE2"
			breaksw
		default:
			echo "$proc_type is not tested"
	endsw
	$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" ${proc_type}_syslog.logx
	$grep "${msg}\[.*\]:" ${proc_type}_syslog.logx >&! ${proc_type}.logx
	if ( $status ) then
		echo "YDB-E-ERROR: $msg is not present in the operator log"
	endif
end
$gtm_tst/com/dbcheck.csh -extract
