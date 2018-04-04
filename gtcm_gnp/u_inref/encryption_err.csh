#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2009, 2013 Fidelity Information Services, Inc	#
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

if ($test_encryption != "ENCRYPT") then
	echo "encryption_err requires ENCRYPT, but got '$test_encryption'. Exiting."
	exit 1
endif

echo "GT.CM ENCRYPTION TEST STARTS"
source $gtm_tst/com/dbcreate.csh mumps 4 -key=40 -rec=512

echo "-------------------------------------------------------------------"
echo "Stop already running GTCM SERVERS"
echo "-------------------------------------------------------------------"
set stop_time_stamp1 = `date +%H_%M_%S`
$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; cd SEC_DIR_GTCM; $gtm_tst/com/GTCM_SERVER_STOP.csh $stop_time_stamp1 >&! gtcm_stop_${stop_time_stamp1}.log"

set time_stamp = `date +%H_%M_%S`

echo "-------------------------------------------------------------------"
echo "After unsetting gtm_passwd on the remote hosts, restart the SERVERS"
echo "-------------------------------------------------------------------"
$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; cd SEC_DIR_GTCM; unsetenv gtm_passwd ;$gtm_tst/com/GTCM_SERVER.csh PORTNO_DEFINED_GTCM $time_stamp >&! SEC_DIR_GTCM/gtcm_start_${time_stamp}.log"

echo "-------------------------------------------------------------------"
echo "Do updates locally to reflect them in the remote GT.CM servers"
echo "-------------------------------------------------------------------"
# Make small updates locally. If one of the remote GT.CM servers supports encryption, then one or more of the updates below
# should generate YDB-E-CRYPTINIT error.
$GTM << EOF >>& local_err.outx
s ^a=10
s ^b=10
s ^c=10
s ^d=10
EOF

set test_failed = "FALSE"
set cnt = `setenv | $grep -E "tst_remote_dir_[0-9]" | wc -l`
set cntx=1
while ($cntx <= $cnt)
	eval 'set each_gtcm_server = $tst_remote_host_'$cntx':r:r:r:r'
	eval 'set each_gtcm_server_dir = $SEC_DIR_GTCM_'$cntx
	eval 'set each_gtcm_server_image = $remote_image_gtcm_'${each_gtcm_server}
	$rsh $each_gtcm_server "$gtm_tst/com/is_encrypt_support.csh $remote_ver $each_gtcm_server_image" >& crypt_support_${each_gtcm_server}.outx
	set is_encrypt_supported = `cat crypt_support_${each_gtcm_server}.outx`
	if ("TRUE" == "$is_encrypt_supported") then
		$rsh $each_gtcm_server  "source $gtm_tst/com/remote_getenv.csh $each_gtcm_server_dir; cd $each_gtcm_server_dir; $gtm_tst/com/check_error_exist.csh cmerr_${time_stamp}.log CRYPTINIT CRYPTBADCONFIG" 	\
			>&! ${each_gtcm_server}_err.outx
		$grep -E "CRYPTINIT|CRYPTBADCONFIG" local_err.outx >&! /dev/null
		set stat1 = $status
		$grep -E "CRYPTINIT|CRYPTBADCONFIG" ${each_gtcm_server}_err.outx >&! /dev/null
		set stat2 = $status
		if (0 != $stat1 || 0 != $stat2) then
			set test_failed = "TRUE"
			echo "TEST-E-FAILED, YDB-E-CRYPTINIT was expected on ${each_gtcm_server} server logs and local log, but "
			echo "not found. Check local_err.outx and ${each_gtcm_server}_err.outx and the GT.CM server log file on "
			echo "the server ${each_gtcm_server}"
		endif
	endif
	@ cntx = $cntx + 1
end

if ("FALSE" == "$test_failed") then
	echo "If there are no errors above, it means the error - YDB-E-CRYPTINIT was seen wherever it is supposed to occur"
endif
echo "GT.CM ENCRYPTION TEST ENDS"
$gtm_tst/com/dbcheck.csh
