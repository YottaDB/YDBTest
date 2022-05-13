#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
	#some of these variables are form older tests and may be outdated
#setenv test_specific_gde $gtm_tst/$tst/inref/ydb210.gde

$gtm_tst/com/dbcreate.csh mumps $1 >& dbcreate.outx
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.outx
endif

if ($terminalNoKill == 0) then
	#in the event this script is called from an expect script we signal
	#the .exp script that the database creation is finished
	echo "dbcreate complete"
endif

if ("MULTISITE" != $test_replic) then
	# This script was called by a script that started replication without the $MSR test framework.
	# The above "dbcreate.csh" invocation would have started the source and receiver server.
	# The caller script (e.g. r122/u_inref/NULLCOLLtest.csh) will later restart the source server.
	# This can cause issues with the receiver server if the connection is not fully established.
	# This is because the source server would be terminated soon by the caller script but the receiver server
	# would not recognize the fact that the source server was shut down and could still be hung waiting for
	# the connection that will never happen anymore. So wait for the connection to happen before returning
	# from this script. This is easily done by waiting for a history record to be sent across.
	setenv start_time `cat start_time`
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log.updproc -message 'New History Content' -duration 120"
endif

# In the case the caller script starts replication using the MSR test framework (e.g. r122/u_inref/REPLINSTNOHISTtest.csh)
# we will do a similar wait in the caller script. This is because the above "dbcreate.csh" invocation in a MSR case does
# not start the replication servers. It is done in the caller script.

