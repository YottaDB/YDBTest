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
# Set white box testing environment to avoid assert failures along with REPLMULTINSTUPDATE error
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 137
setenv gtm_repl_instance "mumps.repl"

$MULTISITE_REPLIC_PREPARE 4

echo "# Create the DB"
# Set up a non replicated region HREG for our trigger activities (the 9th region from the dbcreate)
# Relies on the existance of HREG, hence the 9 region DB
setenv gtm_test_repl_norepl 1
$gtm_tst/com/dbcreate.csh mumps 9 -gld_has_db_fullpath >>& dbcreate.out
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

echo "# run updateINST3^ydb312gtm8182a.m to write variable to INST3 DB to read later"
#$MSR RUN INST3 '$gtm_dist/mumps -run ^%XCMD "set force^=3'
$gtm_dist/mumps -run updateINST3^ydb312gtm8182a
echo ""


echo "# run ydb312gtm8182a.m to:"
echo "#  	-update INST1"
echo "#  	-read from INST3"
echo "#  	-show attached processes of each INST JNLPOOL"
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
