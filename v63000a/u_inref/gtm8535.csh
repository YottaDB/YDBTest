#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# GTM-8535 SIG-11 when 32K process limit is reached for the instance file if QDBRUNDOWN is not enabled

echo "-----------------------------------------------------------------------------------------------------------------"
echo "Test 32K counter semaphore overflow when QDBRUNDOWN is not enabled in replication instance file AND database file"
echo "-----------------------------------------------------------------------------------------------------------------"

setenv gtm_test_qdbrundown 0		# so db and instance file is created without qdbrundown enabled
setenv gtm_test_qdbrundown_parms ""	# also needed to disable qdbrundown
setenv gtm_db_counter_sem_incr 1	# so 4 processes are needed to reach the 32K limit
unsetenv gtm_custom_errors		# that way opening the database does not automatically open the jnlpool
					# this is needed so we can test the db and instance file overflow separately
$gtm_tst/com/dbcreate.csh mumps

if ("HOST_SUNOS_SPARC" == $gtm_test_os_machtype) then
	setenv gtm_db_counter_sem_incr 16384	# so 4 processes are needed to reach the 64K limit
else
	setenv gtm_db_counter_sem_incr 8192	# so 4 processes are needed to reach the 32K limit
endif
$gtm_dist/mumps -run db^gtm8535

setenv gtm_custom_errors /dev/null	# to ensure jnlpool is opened first (ahead of db) so overflow happens in jnlpool
$gtm_dist/mumps -run repl^gtm8535

$gtm_tst/com/dbcheck.csh
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0	# cleanup ipcs that might be leftover due to 32K overflow
echo "----------------------------------------------------------------------------------------------------"
echo "Expect ENO34 errors in dbchild4.mje and replchild4.mje to be caught by error-catching test framework"
echo "----------------------------------------------------------------------------------------------------"
