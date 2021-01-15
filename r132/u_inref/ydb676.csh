#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#0
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 1

echo "# Start replication, do a dummy update, sync and stop to prepare for the fetchresync rollback."
$MSR START INST1 INST2 RP
$ydb_dist/yottadb -run %XCMD 'set ^dummyupdate=1'
$MSR SYNC ALL_LINKS
$MSR STOP ALL_LINKS

echo "# Find port number of INST2 (i.e. value of __RCV_PORTNO__ inside MSR command) and store it for non-MSR use"
set inst2_port = `$MSR RUN INST2 'set msr_dont_trace ; cat portno'`

echo "# Start fetchresync rollback as a background job"
$MSR RUN RCV=INST2 '$MUPIP journal -rollback -fetchresync='$inst2_port' -backward -losttrans=fetch.glo "*" >& rollback.log &'

echo '# Wait for rollback to reach the state where it is waiting for a connection before proceeding to "nc"'
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log rollback.log -message "Waiting for a connection" -waitcreation'

echo "# Start nc to send bad input to fetchresync rollback to make sure it terminates gracefully"
echo "# Previously, we saw the following failures:"
echo "# Debug build : %YDB-F-ASSERT, Assert failed in sr_unix/gtmrecv_fetchresync.c line 454 for expression (FALSE)"
echo "# Release build : Message of unknown type (2092475667) received"
cat /dev/urandom | nc localhost $inst2_port >& nc_stderr.out

echo "# Wait for the background process to finish before proceeding to dbcheck.csh"
# This was copied from the endiancvt/endiancvt_db test
wait
set wait_status = $status
if ($wait_status) then
	echo "TEST-E-WAIT the command wait failed with the status $wait_status"
endif

$gtm_tst/com/dbcheck.csh >>& dbcheck.log

