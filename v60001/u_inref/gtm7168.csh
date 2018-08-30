#!/usr/local/bin/tcsh -f
#################################################################
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
# This module is derived from FIS GT.M.
#################################################################

# This is to test the replication log for the keep_alive settings.

$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.outx

## Make sure the source server and receiver server completes the handshake
setenv start_time `cat start_time`
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log RCVR_'${start_time}'.log.updproc -message "New History Content" -duration 120'
setenv keepalive_settings `$sec_shell '$grep "SO_KEEPALIVE is ON" $SEC_DIR/RCVR_'${start_time}.log''`
echo $keepalive_settings

$gtm_tst/com/dbcheck.csh >& dbcheck.outx
#==================================================================================================================================
