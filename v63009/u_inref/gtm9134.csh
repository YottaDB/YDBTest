#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2020-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$MULTISITE_REPLIC_PREPARE 2

$gtm_tst/com/dbcreate.csh mumps 1

echo "# Start replication"
$MSR START INST1 INST2

# Before stopping the source and receiver servers, ensure they have connected. Or else we could get an INSUNKNOWN error
# when the receiver is restarted a little later in case the test framework chooses "test_replic_suppl_type"
# env var of 1 (i.e. A->P connection where P is supplementary).
get_msrtime
set start_time=$time_msr
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log RCVR_'${time_msr}'.log -message "New History Content"'

echo "# Stop the source server"
$MSR STOPSRC INST1 INST2

echo "# Stop the receiver server"
$MSR STOPRCV INST1 INST2

echo "# Obtain the port number"
source $gtm_tst/com/portno_acquire.csh >>& portno.out

echo "# Start receiver server and make it wait for a connection"
$MSR STARTRCV INST1 INST2

echo "# Give receiver server bad input before connecting to source server"
cat /dev/urandom | nc localhost $portno >& nc_stderr.out

echo "# Start source server"
$MSR STARTSRC INST1 INST2

$gtm_tst/com/dbcheck.csh >>& dbcheck.log
