#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# SRC_SHUT.csh [replication flag]
#	Shut down the source server and turn replication off if explicitly asked
#
set exit_stat = 0
if ( ("V4" == `echo $gtm_exe:h:t|cut -c1-2`) || ("V50000" == `echo $gtm_exe:h:t|cut -c1-6`) ) then
	# this means the current GT.M version is a pre-multisite_replic version and so we need to call
	# V4 counterpart of SRC_SHUT.csh as this script will complain for new qualifiers with older GT.M version.
	$gtm_tst/com/v4_SRC_SHUT.csh $argv
	exit
endif
# Include -l option to have the "Process State" information. But not including it in the default $ps as it has some column issues
set ps = "${ps:s/ps /ps -l /}"	#BYPASSOK ps
if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
endif
# $2 will be for the addtional qualifiers if any that the script will accept and process it for shutdown commands in the future.
# If it turns out to be more than one qualifier for $2 as say $2="updateresync nodeljnl" or some such then we will need to append "-" before every qualifier here.
if ($2 != "") then
	set arg="-$2"
else
	set arg
endif
set time_stamp = `date +%H_%M_%S`
set debuginfo_file = "SRCSHUT_${time_stamp}_failed.outx"
$MUPIP  replic -source $arg $gtm_test_instsecondary -shutdown -timeout=0
set mupipstat = $status
if ($mupipstat) then
	if (! $?gtm_test_other_bg_processes) then
		echo "Primary server shutdown command failed (status was $mupipstat)!"
		echo "Check the file $debuginfo_file for ipcs and ps details"	#BYPASSOK
		echo "Primary server shutdown command failed (status was $mupipstat)!"	>>&! $debuginfo_file
		$gtm_tst/com/ipcs -a							>>&! $debuginfo_file
		$ps									>>&! $debuginfo_file
		set exit_stat = $mupipstat
	else
		echo "TEST-I-SRC_SHUT there are other background GTM processes, so MUPIP might have returned non-zero, ignoring error"
	endif
endif
setenv repl_state "$1"
if ( "off" == $repl_state ) then
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
	$MUPIP set -replic=off -reg "*"
	set mupipstat = $status
	if ($mupipstat) then
		echo  "TEST-E-SRC_SHUT Turning replication off for all regions on primary side failed (status was $mupipstat)!"
		echo  "Check the file $debuginfo_file for ipcs and ps details"	#BYPASSOK
		echo  "Turning replication off for all regions on primary side failed (status was $mupipstat)!" >>&! $debuginfo_file
		$gtm_tst/com/ipcs -a 										>>&! $debuginfo_file
		$ps												>>&! $debuginfo_file
		set exit_stat = 1
	endif
endif
if (0 == $exit_stat) then
	echo "SRC_SHUT_SUCCESSFUL"
endif
exit $exit_stat
