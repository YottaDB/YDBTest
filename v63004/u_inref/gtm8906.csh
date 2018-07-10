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

setenv roll_or_rec `$gtm_tst/com/genrandnumbers.csh`

$MULTISITE_REPLIC_PREPARE 2

# Disable counter semaphore overflow in this test as that means a call to leftover_ipc_cleanup.csh at various places
# (or else one would get a MUUSERLBK error occasionally) and that just side tracks the main purpose of this test
# which is to test huge # of tokens in backward processing of journal recover/rollback.
unsetenv gtm_db_counter_sem_incr

unsetenv gtmdbglvl # Turn off gtmdbglvl as it might significantly increase test runtimes

echo "# Create a single region DB with region DEFAULT"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

# Start only source server, not receiver server as that would slow down test runtime (to replicate millions of updates across).
$MSR STARTSRC INST1 INST2

mkdir bak1
$MUPIP backup "*" bak1 >& backup.out

set numupdates = "55000000"
echo "# Run gtm8906.m to update the DB $numupdates times (this used to issue a MEMORY error in prior versions)"
echo "# The release note of GTM-8906 talks about getting GTM-F-MEMORY errors while handling half a billion updates in V63003"
echo "# But we noticed the errors happening even with about $numupdates updates hence we limit this test to this number"
$ydb_dist/mumps -run gtm8906 $numupdates

$MSR STOPSRC INST1 INST2

$gtm_tst/com/backup_dbjnl.csh dbbkup1 "*.dat" mv
cp bak1/*.dat .

if ($roll_or_rec == 1) then
	echo 'MUPIP JOURNAL -ROLLBACK'
	set logfile = "rollback.log"
	$MUPIP JOURNAL -ROLLBACK -forward -verify "*" >& $logfile
else
	echo 'MUPIP JOURNAL -RECOVER'
	set logfile = "recover.log"
	$MUPIP JOURNAL -RECOVER -forward -verify "*" >& $logfile
endif

# Filter out non-deterministic output from the rollback/recover and keep the rest as part of the reference file.
$grep -vE "REPLSTATE|JNLSTATE|RLBKJNSEQ|RLBKSTRMSEQ|MUJNLPREVGEN" $logfile

# We do not want an rf sync between INST1 and INST2 (since that will take a long time to run and is unrelated to this test
# which is about recover/rollback on INST1. So skip that part with the below env var.
setenv gtm_test_norfsync
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
