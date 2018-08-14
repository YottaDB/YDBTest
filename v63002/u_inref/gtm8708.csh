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
echo "# -------------------------------------------------------------------------------------------------------"
echo "# Test that update helper writer process avoids retrying the epoch repeatedly in case of an idle instance"
echo "# -------------------------------------------------------------------------------------------------------"

echo "# Set 1 writer and 0 reader update helper processes"
# We manually start and stop helpers, so we don't need the random set.
setenv gtm_test_updhelpers 1,0
echo "# override gtm_test_updhelpers in test"		>>! settings.csh
echo "setenv gtm_test_updhelpers $gtm_test_updhelpers"	>>! settings.csh

$MULTISITE_REPLIC_PREPARE 2

echo "# Set epoch_interval to small value (1 second) so as to measure helper writer process across multiple epoch intervals"
setenv tst_jnl_str "$tst_jnl_str,epoch=1"
echo "# Create database on INST1/INST2"
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif

$MSR START INST1 INST2

$MSR RUN INST2 '$ydb_dist/mumps -run gtm8708'

echo "# Do dbcheck on INST1/INST2"
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck.out
	exit -1
endif
