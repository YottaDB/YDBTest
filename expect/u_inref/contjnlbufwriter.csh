#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# With 16K counter semaphore bump per process, the 32K counter overflow happens with just 2 processes
# and affects the calculations of this very sensitive test. So disable counter overflows.
unsetenv gtm_db_counter_sem_incr

setenv tst_jnl_str "$tst_jnl_str,epoch_interval=1"
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -region "*" $tst_jnl_str >& jnl_on.out
# set the buffer flush timer to very high value, so that timer pop-up wont interfer with the testing.
$MUPIP set -flush_time=1000 -reg "*"
# Code change as part of WHITE BOX TEST ensures that process SUSPEND itself while holding the lock on journal buffer.
# Note that due to code changes in GT.M V6.3-005, the suspend while inside jnl_sub_qio_start() is deferred until we
# release the journal buffer now_writer lock so the original intent of this test is no longer satisfied. This test is
# therefore changed to now recognize that the process does get suspended but when it does, the journal qio lock is no longer held.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 82
# Since the process holding journal buffer is locked, on few platform we can't attach it to the debugger. And precisely
# this is what GET_C_STACK_FROM_SCRIPT macro does. Hence unsetenv gtm_procstuckexec.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_procstuckexec gtm_procstuckexec

setenv TERM xterm
set syslog_start = `date +"%b %e %H:%M:%S"`
expect -f $gtm_tst/$tst/u_inref/gtm4661c.exp | tr '\r' ' ' >&! gtm4661c.expected

setenv proc1 `$tst_awk -F= '/^proc1=[0-9]+/{print $2}' gtm4661c.expected`
setenv proc2 `$tst_awk -F= '/^proc2=[0-9]+/{print $2}' gtm4661c.expected`
echo "Process 1 pid = $proc1"
echo "Process 2 pid = $proc2"

echo "# Verify that proc1 has written Suspended message on terminal"
$gtm_tst/com/grepfile.csh 'Suspended (signal)' gtm4661c.expected 1

echo "# Verify that proc2 finds proc1 no longer owns jnl qio lock"
$grep "^jnl qio lock owner pid" gtm4661c.expected

# Get all syslog messages from proc1 and proc2
$gtm_tst/com/getoper.csh "$syslog_start" "" test_syslog.txt

# Verify that,
# - proc1 has sent SUSPENDING message to the operator log i.e. the proc1 is suspended.
# - proc2 has NOT sent JNLPROCSTUCK message to the operator log
# - proc2 has NOT sent REQ2RESUME message to the operator log
$grep -E "\<$proc1\>.*SUSPENDING|\<$proc2\>" test_syslog.txt

$gtm_tst/com/wait_for_proc_to_die.csh $proc1 120
$gtm_tst/com/wait_for_proc_to_die.csh $proc2 120
unsetenv gtm_white_box_test_case_enable	# as otherwise mupip rundown invoked by leftover_ipc_cleanup_if_needed.csh could hang
$gtm_tst/com/dbcheck.csh

exit 0
