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
setenv gtm_repl_instance "mumps.repl"

# Assign the KEY2BIG error to the list of 'serious' errors worth freezing the instance for
cp $ydb_dist/custom_errors_sample.txt .
setenv gtm_custom_errors `pwd`/custom_errors_sample.txt
chmod +w `pwd`/custom_errors_sample.txt
echo "KEY2BIG" >> `pwd`/custom_errors_sample.txt
unsetenv ydb_custom_errors

# once the error is generated we'll freeze the associated instance
setenv gtm_test_freeze_on_error 1
### global key of >5 characters will trigger the KEY2BIG error
##setenv keysize 5

$MULTISITE_REPLIC_PREPARE 4

echo "Test A: INST3-INST4 jnlpool is up on INST3"
echo "-------------------------------------------------"
echo ""
echo "# Create the DB"
#$gtm_tst/com/dbcreate.csh mumps 1 $keysize -gld_has_db_fullpath >>& dbcreate.out
$gtm_tst/com/dbcreate.csh mumps 1 -key_size=5 -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif

echo "# Start INST1 INST2 replication"
$MSR START INST1 INST2
echo ""
echo "# Start INST3 INST4 replication"
$MSR START INST3 INST4
echo ""

#These env vars will be needed by ydb312gtm8182c.m and will still be valid after
#the new db is created in Test B
setenv path_INST1 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
setenv path_INST3 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST3 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`

echo "# Run ydb312gtm8182c.m to trigger a KEY2BIG error in INST3 (should cause INST3 to freeze)"
$gtm_dist/mumps -run ydb312gtm8182c
echo ""

echo "# Unfreeze INST3"
#-freeze=off needs to be done before shutting down INST3-INST4 source server
$MSR RUN INST3 "$MUPIP replic -source -freeze=off"
echo ""

echo "# Stop INST1 INST2 replication"
$MSR STOP INST1 INST2
echo ""
echo "# Stop INST3 INST4 replication"
$MSR STOP INST3 INST4
echo ""

echo "# Check and shutdown the DB"
$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif

echo "# DB has shutdown gracefully"
echo ""


echo "Test B: INST3-INST4 jnlpool is down on INST3"
echo "-------------------------------------------------"
echo ""

echo "# Create the DB"
#$gtm_tst/com/dbcreate.csh mumps 1 $keysize -gld_has_db_fullpath >>& dbcreate.out
$gtm_tst/com/dbcreate.csh mumps 1 -key_size=5 -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif

echo "# Start INST1 INST2 replication"
$MSR START INST1 INST2
echo ""
echo "# Start INST3 INST4 replication"
$MSR START INST3 INST4
echo ""
echo "# Stop INST3 INST4 replication"
$MSR STOP INST3 INST4
echo ""

echo "# Run ydb312gtm8182c.m to trigger a KEY2BIG error in INST3"
$gtm_dist/mumps -run ydb312gtm8182c
echo ""

echo "# Stop INST1 INST2 replication"
$MSR STOP INST1 INST2
echo ""


echo "# Check and shutdown the DB"
$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif
echo "# DB has shutdown gracefully"
