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

# Make DB 1 with global directory of gbl_dir1
echo "Create the DB"
echo ""
#$gtm_tst/com/dbcreate.csh -gld_has_db_fullpath gbl_dir1/mumps 2 >>& dbcreate.out
$gtm_tst/com/dbcreate.csh mumps 2 >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif

$MSR START INST1 INST2
echo ""
$MSR START INST3 INST4
echo ""



#echo "Grep on msr instance config file"
#$grep -e "DBDIR" msr_instance_config.txt
#echo ""


##OLD AWK EDIT FOR msr_instance_config.txt##
#$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $0"/gbl_dir1";else print $0   }' $tst_working_dir/msr_instance_config.txt >&! $tst_working_dir/tmp_msr_instance_config_{$$}.txt
#mv $tst_working_dir/msr_instance_config.txt $tst_working_dir/msr_instance_config_original.txt
#mv $tst_working_dir/tmp_msr_instance_config_{$$}.txt $tst_working_dir/msr_instance_config.txt
#
#$tst_awk '{-F " "; if ($1" "$2 ~ /INST2 DBDIR/)  print $0"/gbl_dir2";else print $0   }' $tst_working_dir/msr_instance_config.txt >&! $tst_working_dir/tmp_msr_instance_config_{$$}.txt
#mv $tst_working_dir/tmp_msr_instance_config_{$$}.txt $tst_working_dir/msr_instance_config.txt
#
#$tst_awk '{-F " "; if ($1" "$2 ~ /INST3 DBDIR/)  print $0"/gbl_dir3";else print $0   }' $tst_working_dir/msr_instance_config.txt >&! $tst_working_dir/tmp_msr_instance_config_{$$}.txt
#mv $tst_working_dir/tmp_msr_instance_config_{$$}.txt $tst_working_dir/msr_instance_config.txt

setenv path_INST1 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
setenv path_INST2 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST2 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
setenv path_INST3 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST3 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`

echo "path_INST1: $path_INST1"
echo "path_INST2: $path_INST2"
echo "path_INST3: $path_INST3"
echo ""

##The replic instance file will be changed in gtm8182.m
##setenv gtm_repl_instance "GARBAGE VALUE"
##setenv ydb_gbldir "./gbl_dir2/mumps.gld"
#
## Make DB 2 with global directory of gbl_dir2
#$GDE change -instance -filename="./gbl_dir2/mumps.repl"
#
#echo "Create DB with gbl_dir2"
#echo ""
#$gtm_tst/com/dbcreate.csh gbl_dir2/mumps 2 >>& dbcreate.out
#if ($status) then
#	echo "DB Create Failed, Output Below"
#	cat dbcreate.out
#	exit -1
#endif
#
#$MSR START INST1 INST3
echo "Check the DB"
echo ""
$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif
