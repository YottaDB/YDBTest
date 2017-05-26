#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
##############################################################################################################
# this script shuts down the receiver server either gracefully or as kill -9 based on random decision
# if crashed then we should follow up with rollback command to ensure the test continues after this point
##############################################################################################################
if ( "" != $1 ) then
	setenv shut_time $1
else
	setenv shut_time `date +%H_%M_%S`
endif
#
if ( 0 == $rolling_upgrade_shut_kill ) then
	# this is crash case
	$gtm_tst/com/receiver_crash.csh "NO_IPCRM" >&! rcvr_sideB_crash.out
	if ($status) then
		echo "FAIL to crash receiver"
		exit 1
	endif
	# mupip journal rollback should be done to make the crashed instance usable.
	# But it should be done using the old version and not the current version.
	# Make sure journal rollback does NOT work if attempted with the current version (will fail with GTM-E-VERMISMATCH)
	$gtm_tst/com/backup_dbjnl.csh crashed_${msver} '*.gld *.dat *.repl' 'cp' 'nozip'
	\rm $gtm_repl_instance # recreated below

	source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
	$MUPIP replic -instance_create -name=$gtm_test_cur_sec_name $gtm_test_qdbrundown_parms
	$GDE exit >>&! gde_${tst_ver}.out
	# Below backward rollback invocation is expected to fail. Therefore pass "-backward" explicitly to mupip_rollback.csh
	# (and avoid implicit "-forward" rollback invocation that would otherwise happen by default).
	$gtm_tst/com/mupip_rollback.csh -backward -fetchresync=$portno -losttrans=RCVR_SHUT_oldver.lost "*" >&! rollback_sideB_${tst_ver}.outx
	if !($status) then
		echo "TEST-E-FAIL mupip journal rollback using current version is expected to fail with GTM-E-VERMISMATCH, but succeeded"
		exit 1
	endif

	# Now attempt journal rollback using oldver. It should work
	$sv_oldver
	cp -p crashed_${msver}/* .
	$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=$portno -losttrans=RCVR_SHUT_oldver.lost "*" >&! rollback_sideB_pass.out
	if !($status) then
		echo "PASS"
	else
		echo "FAIL rollback failed"
		exit 1
	endif
	mkdir save_after_rollbck
	cp mumps.gld mumps.repl *.dat *.mjl* save_after_rollbck/
	# if version is prior to V6.0-002 rundown is necessary (GTM-7698)
	if (`expr "$msver" "<" "V60002"`) then
		$gtm_tst/com/backup_dbjnl.csh after_rollback_${msver} '*.gld *.dat *.repl' 'cp'
		$MUPIP rundown -region "*" >&! rundown_sideB.outx
	endif
else
	$gtm_tst/com/RCVR_SHUT.csh "." >&! SHUT_${shut_time}.out
	if !($status) then
		echo "PASS"
	else
		echo "FAIL to shutdown receiver"
	endif
endif
#
