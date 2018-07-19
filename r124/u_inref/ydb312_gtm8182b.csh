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

echo "Create the DB"
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
echo "# Start INST3 INST4 replication"
$MSR START INST3 INST4
echo ""

setenv path_INST1 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
setenv path_INST3 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST3 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`


echo "# Run ydb312gtm8182b to store results of ZREALSTOR to a file before and after 1000 ZPEEKs"
$gtm_dist/mumps -run ydb312gtm8182b >& zpeeks.txt

cat zpeeks.txt
echo ""

setenv zpeek_before `$grep 'BEFORE $ZPEEK' zpeeks.txt | $tst_awk '{print $6}'`
setenv zpeek_after `$grep 'AFTER  $ZPEEK' zpeeks.txt | $tst_awk '{print $6}'`

if ( $zpeek_before == $zpeek_after ) then
	echo "# NO MEMORY LEAK DETECTED"
else
	echo "# MEMORY LEAK DETECTED"
endif

echo ""


echo "Check and shutdown the DB"
echo "----------------------------------------------------------------------------"
$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif
echo "DB has shutdown gracefully"

