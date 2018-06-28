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
$MULTISITE_REPLIC_PREPARE 4
##setenv gtm_repl_instance "./gbl_dir1/mumps.repl"
#$ydb_dist/mumps -run gtm4212
##setenv ydb_gbldir "mumps.gld"
setenv gtm_repl_instance "mumps.repl"

# Make DB 1 with global directory of gbl_dir1
echo "Create the DB"
echo ""
$gtm_tst/com/dbcreate.csh mumps 2 -gld_has_db_fullpath >>& dbcreate.out
#$gtm_tst/com/dbcreate.csh mumps 2 >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif

$MSR START INST1 INST2
echo ""
$MSR START INST3 INST4
echo ""




setenv path_INST1 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
#setenv path_INST2 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST2 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
setenv path_INST3 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST3 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
#setenv path_INST4 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST4 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`

#echo "path_INST1: $path_INST1"
#echo "path_INST2: $path_INST2"
#echo "path_INST3: $path_INST3"
#echo "path_INST4: $path_INST4"
#echo ""

echo "# Run gtm8182.m to update both INST1 and INST3 source server"
$gtm_dist/mumps -run gtm8182


echo "Check the DB"
echo ""
#$gtm_tst/com/dbcheck.csh -gld_has_db_fullpath >>& check.out
$gtm_tst/com/dbcheck.csh >>& check.out

if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif
