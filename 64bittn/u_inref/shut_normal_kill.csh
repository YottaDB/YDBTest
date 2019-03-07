#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
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
	$gtm_tst/com/receiver_crash.csh >&! rcvr_sideB_crash.out
	if ($status) then
		echo "FAIL to crash receiver"
		exit 1
	endif
	# mupip journal rollback should be done to make the crashed instance usable.
	# Note: The rollback is done using the old version and not the current version.
	$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=$portno -losttrans=RCVR_SHUT_oldver.lost "*" >&! rollback_sideB_pass.out
	if !($status) then
		echo "PASS"
	else
		echo "FAIL rollback failed"
		exit 1
	endif
	mkdir save_after_rollbck
	cp mumps.gld mumps.repl *.dat *.mjl* save_after_rollbck/
else
	$gtm_tst/com/RCVR_SHUT.csh "." >&! SHUT_${shut_time}.out
	if !($status) then
		echo "PASS"
	else
		echo "FAIL to shutdown receiver"
	endif
endif
#
