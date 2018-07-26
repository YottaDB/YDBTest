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

$MULTISITE_REPLIC_PREPARE 4

echo "# Create the DB"
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif
echo ""
echo ""

setenv path_INST1 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
setenv path_INST3 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST3 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`

echo "# start INST1-INST2 and INST3-INST4 connections"
$MSR START INST1 INST2
$MSR START INST3 INST4
echo ""

echo "# Unset gtm_custom_error if it exists as ydb312_gtm8182a relies on this"
if ($?gtm_custom_error) then
	set gtmCustomErrors=$gtm_custom_errors
	unsetenv gtm_custom_errors
endif
echo ""


echo "# run updateINST3^ydb312gtm8182a.m to write variable to INST3 DB to read later"
$gtm_dist/mumps -run updateINST3^ydb312gtm8182a
echo ""

echo "# Reset gtm_custom_error if it was unset"
if ($?gtmCustomErrors) then
	setenv gtm_custom_errors $gtmCustomErrors
	unset $gtmCustomErrors
endif
echo ""
echo ""


echo "# run ydb312gtm8182a.m to:"
echo "#  	-update INST1"
echo "#  	-read from INST3"
echo "#  	-show attached processes of each INST JNLPOOL (SRC server will be 1 of these processes)"
echo "# We expect 2 processes attached to INST1 JNLPOOL and only 1 process attached to INST3 JNLPOOL".
echo "# To confirm that the mumps process only attaches to INST1 JNLPOOL".
echo ""


$gtm_dist/mumps -run gtm8182a^ydb312gtm8182a
echo ""

echo "# Check and shutdown the DB"
echo "----------------------------------------------------------------------------"
$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif
echo "# DB has shutdown gracefully"
