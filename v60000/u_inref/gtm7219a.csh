#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that following image-type are part of facility for operator log messages.
#	MUPIP
#	GTM
#	DSE
#	LKE
#	DBCERTIFY
#	GTCM
#	GTCM_GNP
# Also verify that if replication is on, instance name is part of facility for operator log messaegs.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 67
setenv gtm_test_mupip_set_version "disable"
#create database with one region
$gtm_tst/com/dbcreate.csh mumps -block_size=1024

foreach image_type ( "MUMPS" "MUPIP" "DSE" "LKE" "DBCERTIFY" "GTCM" "GTCM_GNP" )
	set syslog_before = `date +"%b %e %H:%M:%S"`
	echo "$image_type : syslog_before=$syslog_before" >>&! syslog_time.outx
	switch (  $image_type )
		case "MUMPS":
			# Do enough updates so that the DBFILEXT is logged in operator log
			$gtm_exe/mumps -run %XCMD 'for i=0:1:1000 set ^x(i)=$j(" ",200)'
			breaksw
		case "MUPIP":
			# MUPIP extend will send DBFILEEXT message to operator log
			$MUPIP extend DEFAULT
			breaksw
		case "DSE":
			# When DSE image is initialized, message is sent to operator log as a part of white-box testing.
			$DSE exit
			breaksw
		case "LKE":
			# When LKE image is initialized, message is sent to operator log as a part of white-box testing.
			$LKE exit
			breaksw
		case "DBCERTIFY":
			# When DBCERTIFY image is initialized, message is sent to operator log as a part of white-box testing.
			$gtm_exe/dbcertify scan -outfile=dbcertify_scanreport.scan DEFAULT
			breaksw
		case "GTCM":
			source $gtm_tst/com/portno_acquire.csh >>& portno.out
			$gtm_exe/gtcm_server -service $portno -log gtcm_server.logx -hist
			$gtm_tst/com/wait_for_log.csh -log gtcm_server.logx -message "GTCM_SERVER pid :" -waitcreation
			$tst_awk '{print $NF;exit;}' gtcm_server.logx >&! gtcm_server_pid.log
			@ server_id = `cat gtcm_server_pid.log`
			breaksw
		case "GTCM_GNP":
			source $gtm_tst/com/portno_acquire.csh >>& portno.out
			$gtm_exe/gtcm_gnp_server -service=$portno -log=gtcm_gnp_server.logx
			$gtm_tst/com/wait_for_log.csh -log gtcm_gnp_server.logx -message "pid :" -waitcreation
			$tst_awk '{gsub(/].*/,"",$0); print $NF; exit}' gtcm_gnp_server.logx >! gtcm_gnp_server_pid.log
			@ server_id = `cat gtcm_gnp_server_pid.log`
			breaksw
		default:
			echo "$image_type is not tested"
	endsw
	set syslog_after = `date +"%b %e %H:%M:%S"`
	echo "$image_type : syslog_after=$syslog_after" >>&! syslog_time.outx
	echo "--------------------------------------------------------------" >>&! syslog_time.outx
	if ($?test_replic == 1) then
		setenv msg "YDB\-${image_type}\-INSTANCE1"
	else
		setenv msg "YDB\-${image_type}"
	endif
	$gtm_tst/com/getoper.csh "$syslog_before" "" ${image_type}_syslog.logx  "" $msg
	if ( $status ) then
		cat ${image_type}.logx;
		echo "YDB-E-ERROR: $msg is not present in the operator log"
	endif
	if ( ("GTCM" == $image_type) || ("GTCM_GNP" == $image_type) ) then
	        $kill -15 $server_id >>& ${image_type}_kill.outx
	        $gtm_tst/com/wait_for_proc_to_die.csh $server_id 300
		$gtm_tst/com/portno_release.csh
	endif
end
$gtm_tst/com/dbcheck.csh
