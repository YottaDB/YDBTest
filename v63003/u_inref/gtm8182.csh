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

setenv gtm_repl_instance "mumps.repl"

echo "Create the DB"
$gtm_tst/com/dbcreate.csh mumps 2 -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif
echo ""

$MSR START INST1 INST2
echo ""
$MSR START INST3 INST4
echo ""

setenv path_INST1 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
setenv path_INST3 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST3 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`

echo "# Run gtm8182.m to update both INST1 and INST3 source server"
$gtm_dist/mumps -run gtm8182

echo "# Check INST2 receiver server for update (expecting only ^jake to be defined)"
$MSR RUN INST2 '$MUPIP extract INST2_extract.glo'
echo ""

echo "# Check INST4 receiver server for update (expecting only ^zack to be defined)"
$MSR RUN INST4 '$MUPIP extract INST4_extract.glo'
echo ""

echo "Check the DB"
$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif
echo ""
