#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
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
#
# RF_SHUT: Shuts down current source/receiver server
#		Also turn replication off if explicitly requested
#
# for multisite actions we need a common timestamp for all the logs related to it for easy debugging
if ($?gtm_test_replic_timestamp) then
	setenv shut_time $gtm_test_replic_timestamp
else
	setenv shut_time `date +%H_%M_%S`
endif
# The script will also process the additional qualifier that gets passed on as $2.It will be a part of the shut down
# scripts call below.
#===================================================
# SYNC Servers - Do not sync if gtm_test_norfsync is set
#===================================================
if !($?gtm_test_norfsync) then
	$gtm_tst/com/rfstatus.csh "Before_PRI_SEC_Sync"
	$gtm_tst/com/RF_sync.csh
	$gtm_tst/com/rfstatus.csh "After_PRI_SEC_Sync"
endif

#===================================================
# SHUT Down the receiver server and replication off (if explicitly requested)
#===================================================
if (($1 == "on") || ($1 == "")) then
	set repl_state = "."
else if ("off" == $1) then
	echo "Will turn replication off"
	set repl_state = $1
endif
echo "Shutting down Passive Source Server and Receiver Server in $SEC_SIDE"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh $repl_state $2  >>& SHUT_${shut_time}.out ; grep RCVR_SHUT_SUCCESSFUL SHUT_${shut_time}.out" >&! SHUT_${shut_time}_RCVR_status.out	# BYPASSOK grep
set rcvr_shut = `cat SHUT_${shut_time}_RCVR_status.out`

#===================================================
# SHUT Down the source server and replication off
#===================================================
echo "Shutting down Primary Source Server Server in $PRI_SIDE"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC_SHUT.csh $repl_state $2  >>& SHUT_${shut_time}.out ; grep SRC_SHUT_SUCCESSFUL SHUT_${shut_time}.out"	>&! SHUT_${shut_time}_SRC_status.out # BYPASSOK grep
set src_shut = `cat SHUT_${shut_time}_SRC_status.out`

if ( ("RCVR_SHUT_SUCCESSFUL" == "$rcvr_shut") && ("SRC_SHUT_SUCCESSFUL" == "$src_shut") ) then
	set rf_shut_status = 0
else
	set rf_shut_status = 1
endif

# For MULTISITE tests portno release is handled separately.
if ( "MULTISITE" != $test_replic ) then
	# If either of the shutdown failed, do not remove the port reservation file
	if (0 == $rf_shut_status) then
		$sec_shell "$sec_getenv; cd $SEC_SIDE; source $gtm_tst/com/portno_release.csh"
	endif
endif

exit $rf_shut_status
