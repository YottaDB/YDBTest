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
echo ""

setenv path_INST1 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`
setenv path_INST3 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST3 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`


echo "# Running rmv_map script in INST3 to remove instance file mapping"
# We set the instance file name of INST3 to NULL so that it no longer has the full path
$MSR RUN INST3 "$gtm_tst/com/rmv_map.csh"
$MSR RUN INST3 "$GDE SHOW -INSTANCE  "
echo ""
echo ""

echo "# Copy ydb312gtm8182e.m to INST3"
cp $gtm_tst/r124/inref/ydb312gtm8182e.m $path_INST3

echo "# Unset [ydb/gtm]_repl_instance env variables  and run ydb312gtm8182e.m to set globals on INST1 and INST3 from INST3"
$MSR RUN INST3 'unsetenv ydb_repl_instance; unsetenv gtm_repl_instance; $gtm_dist/mumps -run ydb312gtm8182e'

echo "# Reset the _repl_instance env vars in INST3"
$MSR RUN INST3 'setenv gtm_repl_instance "mumps.repl"'
$MSR RUN INST3 'setenv ydb_repl_instance "mumps.repl"'

$MSR STOP INST1 INST2
$MSR STOP INST3 INST4

echo "# Check and shutdown the DB"
echo "----------------------------------------------------------------------------"
$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif
echo "# DB has shutdown gracefully"
