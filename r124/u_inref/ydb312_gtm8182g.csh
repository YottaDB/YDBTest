#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
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
unsetenv gtm_db_counter_sem_incr # avoid semaphore counter overflow otherwise they inflate semval which affects the reference file

$MULTISITE_REPLIC_PREPARE 2

echo "# Create the DB"
$gtm_tst/com/dbcreate.csh mumps 2 -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif
echo ""
echo ""

echo "# GBL1.gld is created to point to mumps.dat and mumps.repl"
setenv gtmgbldir "GBL1"
$GDE CHANGE -SEGMENT DEFAULT -FILE=mumps.dat >& gde_change1.txt
echo ""

echo "# GBL2.gld is created to point to a.dat and mumps.repl"
setenv gtmgbldir "GBL2"
$GDE CHANGE -SEGMENT DEFAULT -FILE=a.dat >& gde_change2.txt
echo ""

echo "# Change back to original global directory"
setenv gtmgbldir "mumps"
echo ""

echo '# Start INST1 INST2 replication with mumps.gld as $zgbldir'
$MSR START INST1 INST2
echo ""

setenv path_INST1 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`

echo "# Run ydb312gtm8182g.m to update DB through GBL1.gld and GBL2.gld"
$gtm_dist/mumps -run ydb312gtm8182g
echo ""

echo "# Write variables to the screen from mumps.gld"
echo -n "#     ^Protagonist: "
$ydb_dist/mumps -run ^%XCMD 'WRITE ^Protagonist,!'
echo -n "#     ^Antagonist : "
$ydb_dist/mumps -run ^%XCMD 'WRITE ^Antagonist,!'
echo ""


echo "# Check and shutdown the DB"
$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
	exit -1
endif
echo "DB has shutdown gracefully"

