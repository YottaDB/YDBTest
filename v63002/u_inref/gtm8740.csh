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
#
#

# To avoid the test framework from complaining when we shut down the source server while a mumps process is running
setenv gtm_test_other_bg_processes 1
unsetenv gtm_custom_errors
$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out

$MSR START INST1 INST2
echo ""
$MUPIP REPLIC -SOURCE -JNLPOOL -SHOW >& replicshow.out
$grep Custom replicshow.out
$ydb_dist/mumps -run gtm8740
# Starting a background process so the jnl pool does not get shut down
(($ydb_dist/mumps -run waitfn^gtm8740)&) > background.out
echo ""
echo "# Shutting down primary"
$MSR STOPSRC INST1 INST2
echo ""
echo "# Uploading custom errors"
setenv gtm_custom_errors /dev/null
echo ""

echo "# Restarting primary"
$MSR STARTSRC INST1 INST2
# Ending background process
$ydb_dist/mumps -run ^%XCMD "set ^stop=1"
echo ""
$MUPIP REPLIC -SOURCE -JNLPOOL -SHOW >& replicshow.out
$grep Custom replicshow.out
$ydb_dist/mumps -run gtm8740

unsetenv gtm_test_other_bg_processes
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
