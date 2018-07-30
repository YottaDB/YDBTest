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
echo '# Running GTM-8930 subtest to test $VIEW("JNLPOOL") '
echo '--------------------------------------------------------------------------------'
echo ''


$MULTISITE_REPLIC_PREPARE 2

echo "# Create a 1 region DB with gbl_dir mumps.gld and region DEFAULT" # , AREG, and BREG"
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif
echo ''

echo "# Start replication"
$MSR START INST1 INST2
echo ''

set rand=`$gtm_tst/com/genrandnumbers.csh`

if ($rand) then
	echo "# gtm_repl_instance set to mumps.repl"
	setenv gtm_repl_instance "mumps.repl"
else
	echo "# gtm_repl_instance set to arbitrary.repl (garbage value)"
	setenv gtm_repl_instance "arbitrary.repl"
endif
echo ''

echo "# Map INST1 global directory to mumps.repl"
$GDE CHANGE -INSTANCE -FILE_NAME="mumps.repl" >& gdeChange.txt

echo '# Run test1^gtm8930.m to test $VIEW("JNLPOOL") before and after opening JNLPOOL'
$ydb_dist/mumps -run test1^gtm8930
echo ''


echo "# Remove instance file mapping in GDE"
$GDE CHANGE -INSTANCE -FILE_NAME=\"\" >& gdeChange.txt
echo ''

echo "# Unset gtm_repl_instance"
unsetenv gtm_repl_instance
echo ''

echo '# Run test2^gtm8930.m to test $VIEW("JNLPOOL") with no replication instance file defined'
$ydb_dist/mumps -run test2^gtm8930
echo ''


echo '# Run test3^gtm8930.m to test $VIEW("JNLPOOL") with no instance file mapped and gtm_repl_instance set to an arbitrary value'
setenv gtm_repl_instance "arbitrary.repl"
$ydb_dist/mumps -run test3^gtm8930
echo ''


echo "# Re-set gtm_repl_instance for shutdown"
setenv gtm_repl_instance "mumps.repl"
echo ''

echo '# Shut down the DB'
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
