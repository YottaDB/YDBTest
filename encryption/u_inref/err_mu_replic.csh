#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
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

#This subtest test the behaviour of update process while doing gtm_updates
#without gtm_passwd

# Source and receiver servers are manually started without copying .repl file from primary to secondary.
# Since it is a test for gtm_passwd, to keep it simple force A->B
setenv test_replic_suppl_type 0
setenv save_gtm_passwd $gtm_passwd
$gtm_tst/com/dbcreate_base.csh mumps
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcreate_base.csh mumps"

$MUPIP replic -instance_create -name=$gtm_test_cur_pri_name $gtm_test_qdbrundown_parms
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replic -instance_create -name=$gtm_test_cur_sec_name $gtm_test_qdbrundown_parms"

$MUPIP set -replication=on $tst_jnl_str -REG "*" >>& jnl.log
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -replication=on $tst_jnl_str -REG '*' >>& jnl.log"

setenv portno `$sec_shell "$sec_getenv; source $gtm_tst/com/portno_acquire.csh"`
setenv start_time `date +%H_%M_%S`
$sec_shell "$sec_getenv; echo $portno >&! $SEC_DIR/portno"
echo $start_time >&! $PRI_DIR/start_time

$gtm_tst/com/SRC.csh "." $portno $start_time >>&! $PRI_DIR/START_${start_time}.out

echo "# Start the receiver without gtm_passwd - Expect YDB-W-CRYPTINIT warning in passive server log and update process log"
$sec_shell  "$sec_getenv; cd $SEC_DIR; unsetenv gtm_passwd; $gtm_tst/com/RCVR.csh ""."" $portno $start_time < /dev/null "">&!"" $SEC_DIR/START_${start_time}.out;"

# Check YDB-W-CRYPTINIT error from updateproc log. This error is expected
$gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log.updproc -message "YDB-W-CRYPTINIT" -duration 30 -waitcreation

echo "# Update some globals on primary - Expect update process to exit with YDB-E-CRYPTBADCONFIG"
$gtm_exe/mumps -run %XCMD 'set ^a=10'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log RCVR_${start_time}.log.updproc -message YDB-E-CRYPTBADCONFIG"

echo "# Expect both YDB-W-CRYPTINIT and YDB-E-CRYPTBADCONFIG from update process log"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/check_error_exist.csh RCVR_${start_time}.log.updproc YDB-W-CRYPTINIT YDB-E-CRYPTBADCONFIG"

setenv gtm_passwd $save_gtm_passwd
echo "# Shut down source and receiver processes"
setenv gtm_test_norfsync
$gtm_tst/com/dbcheck.csh

echo "# Expect and filter out YDB-W-CRYPTINIT warning from receiver start log and passive source server log"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/check_error_exist.csh START_${start_time}.out YDB-W-CRYPTINIT"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/check_error_exist.csh passive_${start_time}.log YDB-W-CRYPTINIT"
