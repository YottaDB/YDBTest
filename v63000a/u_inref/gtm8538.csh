#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2001-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

# GTM-8538 MUTEXFRCDTERM messages when 32K processes attach to a read-only replication instance file

echo "-----------------------------------------------------------------------------------------------------------------"
echo "Test it is okay for instance and database file to be read-only to the 32K counter semaphore overflowing process"
echo "-----------------------------------------------------------------------------------------------------------------"

setenv gtm_test_qdbrundown 1			# so db and instance file is created with qdbrundown enabled
setenv gtm_test_qdbrundown_parms "-qdbrundown"	# keep this in sync with "gtm_test_qdbrundown"
setenv gtm_db_counter_sem_incr 1		# keep this at the start
setenv gtm_custom_errors /dev/null	# to ensure jnlpool is opened first (ahead of db) so overflow happens in jnlpool

echo "# Create replicated database and start replication servers on read-write instance file"
$gtm_tst/com/dbcreate.csh mumps

set start_time = `cat start_time`
# Wait for the Source Server to have written/read all information to/from the instance file before we make the instance file
# read-only to avoid any unexpected REPLINSTOPEN (ENO13 Permission denied) errors.
$gtm_tst/com/wait_for_log.csh -message "New History Content" -log SRC_$start_time.log -duration 30

if ("HOST_SUNOS_SPARC" == $gtm_test_os_machtype) then
	setenv gtm_db_counter_sem_incr 16384	# so 4 processes are needed to reach the 64K limit
else
	setenv gtm_db_counter_sem_incr 8192	# so 4 processes are needed to reach the 32K limit
endif
echo "# Make instance file and database file read-only for to-be-started mumps processes"
chmod 444 $gtm_repl_instance mumps.dat
# Starting 4 processes to overflow instance file counter is already taken care of by gtm8535.m so reuse that M program here
echo "# Cause 32K counter overflow on instance file"
set syslog_start1 = `date +"%b %e %H:%M:%S"`
$gtm_dist/mumps -run repl^gtm8535

echo "# Wait for NOMORESEMCNT message"
$gtm_tst/com/getoper.csh "$syslog_start1" "" syslog1.txt "" NOMORESEMCNT
$grep "NOMORESEMCNT.*$PWD" syslog1.txt # grep for NOMORESEMCNT messages only from our test (not other concurrent tests)

echo "# Restore permissions on instance and db file"
chmod 644 $gtm_repl_instance mumps.dat

$gtm_tst/com/dbcheck.csh
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0	# cleanup ipcs that might be leftover due to 32K overflow
mkdir bak
$gtm_tst/com/backup_dbjnl.csh bak "*.gld *.repl *.dat *.mjl*" cp nozip

echo "----------------------------------------------------------------------------------------------"
echo "Test that MUUSERECOV error is not accompanied by incorrect secondary errors (e.g. CRITSEMFAIL)"
echo "----------------------------------------------------------------------------------------------"

unsetenv test_replic		# turn off replication, but create journaled database to test MUUSERECOV
setenv gtm_test_jnl SETJNL
echo "Create journaled (but not replicated) database"
$gtm_tst/com/dbcreate.csh mumps
echo "# Open database and crash"
$GTM << GTM_EOF
	view "JNLFLUSH"
	zsystem "$kill9 "_\$j
GTM_EOF

echo "# Expect MUUSERECOV error from MUPIP INTEG of crashed journaled database"
$MUPIP integ mumps.dat	# should issue MUUSERECOV error
$gtm_tst/com/dbcheck.csh
