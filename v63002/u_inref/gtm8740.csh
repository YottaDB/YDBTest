#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
unsetenv gtm_custom_errors
$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out

$MSR START INST1 INST2
echo ""
$MUPIP REPLIC -SOURCE -JNLPOOL -SHOW >& replicshow.out
$grep Custom replicshow.out
$ydb_dist/mumps -run gtm8740
echo "# Starting a background process so the jnl pool does not get shut down when the source server is stopped"
(($ydb_dist/mumps -run waitfn^gtm8740)&) > background.out
echo "# Ensure background process has done an update (and therefore opened the journal pool)"
$ydb_dist/mumps -run ^%XCMD 'for  quit:$get(^stop)=0  hang 0.01'
echo ""
echo "# Shutting down primary now that we know a background process is attached to the journal pool"
echo "# The source server will not take down the journal pool due to the background process"
# To avoid the test framework from complaining when we shut down the source server while a mumps process is running
setenv gtm_test_other_bg_processes 1
$MSR STOPSRC INST1 INST2
unsetenv gtm_test_other_bg_processes
echo ""
echo "# Uploading custom errors"
setenv gtm_custom_errors /dev/null
echo ""

echo "# Restarting primary"
$MSR STARTSRC INST1 INST2
# Ending background process
$ydb_dist/mumps -run ^%XCMD "set ^stop=1"
set pid=`cat pid.out`
$gtm_tst/com/wait_for_proc_to_die.csh $pid
echo ""
$MUPIP REPLIC -SOURCE -JNLPOOL -SHOW >& replicshow.out
$grep Custom replicshow.out
$ydb_dist/mumps -run gtm8740

$gtm_tst/com/dbcheck.csh >>& dbcheck.out
