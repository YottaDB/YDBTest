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
#
# Test that a line length greater than 8192 bytes produces a LSEXPECTED warning
#

cat << EOF
## Test the mechanism for adaptively adjusting replication logging frequency
##  INST1 --> INST2
EOF

$gtm_tst/com/dbcreate.csh mumps 1

if (! $?portno) then
	setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
endif

if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
endif
## Make sure the source server and receiver server completes the handshake
setenv start_time `cat start_time`
#$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log RCVR_'${start_time}'.log.updproc -message "History has non-zero Supplementary Stream" -duration 120'
$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log RCVR_'${start_time}'.log.updproc -message "New History Content" -duration 120'


echo '# Creating database, setting defer time to 0'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/jnl_on.csh"
set x = `$ydb_dist/mumps -run ^%XCMD "write 2**31-1"`
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -region DEFAULT -replication=on
$MUPIP replicate -RECEIVER -START -LISTENPORT=1234 -LOG=temp.log -LOG_INTERVAL=0
$gtm_tst/com/dbcheck.csh mumps 1 >>& db.txt





