#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
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

if ("ENCRYPT" == "$test_encryption" ) then
	head -n -3 $gtmcrypt_config > $gtmcrypt_config.merged
	foreach inst (INST3)
		echo "        }," >> $gtmcrypt_config.merged
		$MSR RUN $inst "cat $gtmcrypt_config" | tail -6 | head -3 >> $gtmcrypt_config.merged
	end
	tail -n 3 $gtmcrypt_config >> $gtmcrypt_config.merged
	mv $gtmcrypt_config $gtmcrypt_config.orig
	mv $gtmcrypt_config.merged $gtmcrypt_config
endif

echo "# Run ydb312gtm8182f.m to do a SET in INST1, a LOCK in INST3, and a SET in INST3"
$gtm_dist/mumps -run ydb312gtm8182f
echo ""

echo "# Stop INST3 INST4 replication"
$MSR STOP INST1 INST2
$MSR STOP INST3 INST4
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

