#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008-2016 Fidelity National Information		#
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
#
# Test REPLTRANS2BIG error shows up in receiver server log even if compressed record fits in receive pool.
# This is a test that should have been there even for regular replication. Nothing related to compression.
# Having this will ensure we test REPLTRANS2BIG errors both in compressed and non-compressed mode (depending
#      on whether the E_ALL was started with compression enabled or not).
#
echo "# initially have journal pool and receive pool size at 1Mb"
setenv tst_buffsize 1048576	# 1Mb
set smallbuffsize = $tst_buffsize
# Define database parameters big enough to fit a HUGE transaction on the primary and secondary.
$gtm_tst/com/dbcreate.csh mumps 1 -key=255 -rec=1000 -block=1024 -glo=8192

echo "# Create a HUGE update transaction (approx 2Mb jnl size) on the primary"
$gtm_exe/mumps -run updtrans

set timestamp1 = `cat $PRI_DIR/start_time`

#-----------------------------------------------------------------------------------------------------------------
# Define strings to look out for in the log files
#
set connresetstr = "Connection reset"
set trans2bigstr = "YDB-E-REPLTRANS2BIG"
set rcvrexitstr  = "Receiver server exiting"

echo "# Wait for connection reset string to appear in the source server log"
$gtm_tst/com/wait_for_log.csh -log $PRI_SIDE/SRC_$timestamp1.log -message "$connresetstr"

echo "# Wait for receiver server exiting message to appear in the receiver server log"
$gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_$timestamp1.log -message "$rcvrexitstr"

echo "# Make sure REPLTRANS2BIG error exists in receiver server log file"
$gtm_tst/com/check_error_exist.csh $SEC_SIDE/RCVR_$timestamp1.log "$trans2bigstr"

echo "# Shut down receiver side (update process etc.)"
# One could have used RCVR_SHUT.csh but that will throw an error because the receiver server did not shutdown gracefully (because of the REPLTRANS2BIG error).
# Therefore we explicitly shutdown
# A MUPIP RUNDOWN is needed after this but before restarting the receiver server.
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replic -receiv -shut -time=0 < /dev/null >>&! $SEC_SIDE/SHUT_${timestamp1}.out"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replic -source -shut -time=0 < /dev/null >>&! $SEC_SIDE/SHUT_${timestamp1}.out"
$sec_shell "$sec_getenv; cd $SEC_SIDE; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0" # do leftover ipc rundown if needed before doing rundown in test
$sec_shell '$sec_getenv; cd $SEC_SIDE; $MUPIP rundown -reg "*" < /dev/null >>&! $SEC_SIDE/SHUT_'"${timestamp1}"'.out'

setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`

sleep 1	# make sure time chosen below is different from $timestamp1
setenv timestamp2 `date +%H_%M_%S`

echo "# reset receive pool size to 32Mb to accommodate the HUGE transaction"
setenv tst_buffsize 33554432	# 32Mb

$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $timestamp2 < /dev/null "">>&!"" $SEC_SIDE/START_${timestamp2}.out"

echo "# Check that HUGE transaction did get replicated finally"
$gtm_tst/com/dbcheck.csh -extract

echo "# Check that uncompressed message is greater than 1Mb in size. If yes PASS message is NOT displayed."
set replinfotrcmpstr = "^.* : REPL INFO - Jnl Total : [0-9]*  Msg Total : [0-9]*  CmpMsg Total : [0-9]*"
# Sample output
#	Tue Oct 14 15:18:34 2008 : REPL INFO - Jnl Total : 248048  Msg Total : 248056  CmpMsg Total : 4088
#                                                                             ^^^^^^                 ^^^^
# So need to look at $17 and $21
$grep "$replinfotrcmpstr" $PRI_SIDE/SRC_$timestamp1.log | $tst_awk '{if ($17 <= '$smallbuffsize') print "FAIL : Msg Total < 1Mb (Expecting >= 1Mb)";}'
echo "# If run with non-zero gtm_zlib_cmp_level, check that compressed message is less than 1Mb. If yes PASS message is NOT displayed."
if ($?gtm_zlib_cmp_level) then
	if (( 0 < $gtm_zlib_cmp_level) && ( 9 >= $gtm_zlib_cmp_level)) then
		$grep "$replinfotrcmpstr" $PRI_SIDE/SRC_$timestamp1.log | $tst_awk '{if ($21 >= '$smallbuffsize') print "FAIL : CmpMsg Total >= 1Mb (Expecting < 1Mb)";}'
	endif
endif
#echo "# MUNOTALLSEC and SRCSVREXISTS message expected below because source server was running all though the receiver restart"
