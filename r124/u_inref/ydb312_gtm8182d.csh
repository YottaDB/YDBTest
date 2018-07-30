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
$MULTISITE_REPLIC_PREPARE 2

setenv gtm_custom_errors /dev/null

echo "# Create the DB"
$gtm_tst/com/dbcreate.csh mumps 1 -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif
echo ""
echo ""

echo "# Start INST1 INST2 replication"
$MSR START INST1 INST2
echo ""
echo "# Stop INST1 INST2 replication"
$MSR STOP INST1 INST2
echo ""
setenv path_INST1 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`

echo "# Run ydb312gtm8182d.m"
$gtm_dist/mumps -run ydb312gtm8182d
echo ""

$MSR STOPSRC INST1 INST3

echo "# Check and shutdown the DB"
$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif
echo "# DB has shutdown gracefully"

