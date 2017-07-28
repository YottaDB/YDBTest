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
#==========================
# RCVR_SHUT.csh [replication flag] [other qualifiers] [buffer_flush]
# 	Shut down receiver server (and passive source server if applicable)
#	replication flag - if "off", turns off replication ; replication left unchanged otherwise
#	other qualifiers - qualifiers that should be passed to the receiver shutdown command
#	buffer_flush	 - to determine if a dse buffer_flush should be done after the rcvr shutdown and before the passive server shutdown
#==========================
set exit_stat = 0
if ( ("V4" == `echo $gtm_exe:h:t|cut -c1-2`) || ("V50000" == `echo $gtm_exe:h:t|cut -c1-6`) ) then
	# this means the current GT.M version is a pre-multisite_replic version and so we need to call
	# V4 counterpart of RCVR_SHUT.csh as this script will complain for new qualifiers with older GT.M version.
	$gtm_tst/com/v4_RCVR_SHUT.csh $argv
	exit
endif
if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_pri_name"
endif

# $1 will be the replication state.
setenv repl_state "$1"

# $2 will be for the addtional qualifiers if any that the script will accept and process it for shutdown commands in the future.
# If it turns out to be more than one qualifier for $2 as say $2="updateresync nodeljnl" or some such then we will need to append "-" before every qualifier here.
if ($2 != "") then
	set arg="-$2"
else
	set arg
endif

# $3 if set to buffer_flush, a dse -buffer_flush will be done after shutting down the rcvr and before shutting down the passive source server
# Thereby avoiding any timeout during passive source server shutdown
if ("buffer_flush" == "$3") then
	set do_buffer_flush = 1
endif

if ($?gtm_test_replic_timestamp) then
	set timestamp = $gtm_test_replic_timestamp
else
	set timestamp = `date +%H_%M_%S`
endif
set debuginfo_file = "RCVR_SHUT_${timestamp}_failed.outx"
set exit_stat = 0
$MUPIP replic -receiv $arg -shutdown -timeout=0
set mupipstat = $status
if ($mupipstat) then
        echo "Receiver server shutdown on receiver side failed. Status : $mupipstat"
	echo "Check the file $debuginfo_file for ps/ipcs/netstat/lsof -i details"	#BYPASSOK
        echo "Receiver server shutdown on receiver side failed!"	>>&! $debuginfo_file
	$gtm_tst/com/capture_ps_ipcs_netstat_lsof.csh			>>&! $debuginfo_file
	set exit_stat = $mupipstat
endif

if ($?do_buffer_flush) then
	# buffer_flush was passed as 3rd argument and so a dse -buffer_flush is done on all the regions
	$gtm_tst/com/dse_buffer_flush.csh
endif


# check to determine whether there is a passive source server we need to stop.
# since if there was an active source server (PP) already running, a passive source server would not have been started
# this situation is indicated by the presence of no_passive.out created by RCVR.csh
if !( -e no_passive_$gtm_test_cur_pri_name.out ) then
	# we are not processing $arg here for passive source server. This script is mainly for receiver shutdown as the name indicates
	# so the new qualifier added might not fit in for source server shutdown.If its needed then we will process it at that time
	$MUPIP replic -source $gtm_test_instsecondary -shutdown -timeout=0
	set mupipstat = $status
	if ($mupipstat) then
	        echo "Passive source server shutdown on receiver side failed. Status : $mupipstat"
		echo "Check the file $debuginfo_file for ps/ipcs/netstat/lsof -i details"	#BYPASSOK
	        echo "Passive source server shutdown on receiver side failed!"	>>&! $debuginfo_file
		$gtm_tst/com/capture_ps_ipcs_netstat_lsof.csh			>>&! $debuginfo_file
		set exit_stat = $mupipstat
	endif
else
	\rm no_passive_$gtm_test_cur_pri_name.out
endif

if ( -e supp_${gtm_test_cur_sec_name}_dummy.out ) then
	setenv gtm_test_instsecondary "-instsecondary=supp_${gtm_test_cur_sec_name}"
	$MUPIP replic -source $gtm_test_instsecondary -shutdown -timeout=0
	set mupipstat = $status
	if ($mupipstat) then
		echo "Supplementary server shutdown command failed (status was $mupipstat)!"
		echo "Check the file $debuginfo_file for ps/ipcs/netstat/lsof -i details"	#BYPASSOK
	        echo "supplementary source server shutdown on receiver side failed!"	>>&! $debuginfo_file
		$gtm_tst/com/capture_ps_ipcs_netstat_lsof.csh			>>&! $debuginfo_file
		set exit_stat = $mupipstat
	endif
	# Do not release supplementary source server port if shutdown failed
	if ( !($mupipstat) && (-e $SEC_DIR/portno_supp) ) then
		# Release the supplementary port right away. It is not straight forward to hold it and reuse. Fix it if there are any issues due to this release-reaquire of suppl port
		set portno_supp = `cat $SEC_DIR/portno_supp`
		$gtm_tst/com/portno_release.csh $portno_supp
	endif
endif
if ( "off" == $repl_state ) then
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
	$MUPIP set -replic=off -reg "*"
	set mupipstat = $status
	if ($mupipstat) then
		echo "TEST-E-RCVR_SHUT Turning replication off on receiver side failed (status was $mupipstat)!"
		echo "Check the file $debuginfo_file for ps/ipcs/netstat/lsof -i details"	#BYPASSOK
		echo "Turning replication off on receiver side failed!"	>>&! $debuginfo_file
		$gtm_tst/com/capture_ps_ipcs_netstat_lsof.csh		>>&! $debuginfo_file
		set exit_stat = 1
	endif
endif
if (0 == $exit_stat) then
	echo "RCVR_SHUT_SUCCESSFUL"
endif
exit $exit_stat
