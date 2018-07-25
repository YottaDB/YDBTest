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
setenv gtm_repl_instance "mumps.repl"
unsetenv gtm_db_counter_sem_incr # avoid semaphore counter overflow

#setenv ydb_gbldir "GBL3"
#setenv gtmgbldir $ydb_gbldir
#DB3 will be the main DB with its global dir containing DB1 and DB2

$MULTISITE_REPLIC_PREPARE 2

echo "Create the DB"
# create a 2 region DB with mumps.dat tied to DEFAULT and a.dat tied to AREG
$gtm_tst/com/dbcreate.csh mumps 2 -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif
echo ""
echo ""

#C[HANGE] -R[EGION] region-name [-REGION-qualifier...]

#Create the global directory for DB1 and point its GLD towards DB3's mumps.dat DB file
#  add -segment cusseg -file=cus.dat
#  C[HANGE] -S[EGMENT] segment-name [-SEGMENT-qualifier...]

setenv ydb_gbldir "GBL1"
setenv gtmgbldir $ydb_gbldir
setenv GBL1 "GBL1.gld"
$GDE CHANGE -SEGMENT DEFAULT -FILE=mumps.dat
#A[DD] -S[EGMENT] segment-name [-SEGMENT-qualifier...] -F[ILE_NAME]=file-name

#Create the global directory for DB2 and point its GLD towards DB3's a.dat DB file
setenv ydb_gbldir "GBL2"
setenv gtmgbldir $ydb_gbldir
setenv GBL2 "GBL2.gld"
$GDE CHANGE -SEGMENT DEFAULT -FILE=a.dat

#Change back to original global directory
#setenv ydb_gbldir "GBL3"
setenv ydb_gbldir "mumps"
setenv gtmgbldir $ydb_gbldir

echo "# Start INST1 INST2 replication"
$MSR START INST1 INST2
echo ""

setenv path_INST1 `$tst_awk '{-F " "; if ($1" "$2 ~ /INST1 DBDIR/)  print $3}' $tst_working_dir/msr_instance_config.txt`

#echo "# Attached processes before updates"
#$ydb_dist/mupip ftok -jnlpool mumps.repl |& $grep mumps.repl | $tst_awk '{print $6}' >& shm1.out
#ipcs -a | $grep `cat ./shm1.out` | $tst_awk '{print $NF}'
#echo ""

echo "# Run ydb312gtm8182g.m to update DB through GBL1 and GBL2"
$gtm_dist/mumps -run ydb312gtm8182g
echo ""

#echo "# Attached processes after updates"
#$ydb_dist/mupip ftok -jnlpool mumps.repl |& $grep mumps.repl | $tst_awk '{print $6}' >& shm2.out
#ipcs -a | $grep `cat ./shm2.out` | $tst_awk '{print $NF}'
#echo ""

echo "# Write variables to the screen from mumps.gld"
echo -n "#     ^Protagonist: "
$ydb_dist/mumps -run ^%XCMD 'WRITE ^Protagonist,!'
echo -n "#     ^Antagonist : "
$ydb_dist/mumps -run ^%XCMD 'WRITE ^Antagonist,!'
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

