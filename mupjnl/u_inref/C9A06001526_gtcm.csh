#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2010, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

@ rand = `$gtm_exe/mumps -run rand 2`
if ($rand) then
	setenv gtm_error_on_jnl_file_lost "1"
	set expected_jnl_state = "ON"
else
	set expected_jnl_state = "OFF"
endif

echo "Testing that GT.CM callers of jnl_ensure_open() handle non-return success"
echo "On error, journaling should be $expected_jnl_state"

setenv gtm_white_box_test_case_number 43
setenv gtm_white_box_test_case_count 1

setenv gtmgbldir "mumps.gld"

echo "Testing for sr_port_cm/gtcmd_rundown.c"
setenv gtm_white_box_test_case_count 2
setenv gtm_white_box_test_case_enable 1
# It's important to 'source' dbcreate.csh when using GT.CM, otherwise it doesn't work!
source $gtm_tst/com/dbcreate.csh mumps
$rsh $tst_remote_host_1 "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; $MUPIP set -journal=enable,before -file mumps.dat;"
unsetenv gtm_white_box_test_case_enable
$gtm_exe/mumps -run %XCMD 'set ^a=1'
#$gtm_tst/com/dbcheck.csh
#can't use dbcheck.csh because we need to remove gtm_white_box_test_case_enable from SEC_GETENV_GTCM
echo "Stopping the GT.CM Servers..."
$gtm_tst/com/GTCM_STOP.csh gtcm_stop_`date +%H_%M_%S`.log
set stat = $status
if ($stat) echo "TEST-E-GTCMSTOP Error from GTCM_STOP.csh. Check gtcm_stop_*.log on the servers"
echo "Check the databases on the GT.CM Servers..."
$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; unsetenv gtm_white_box_test_case_enable; cd SEC_DIR_GTCM; $gtm_tst/com/dbcheck_base.csh"
if (-e a.dat) then
	echo "Check local (client) database..."
	$gtm_tst/com/dbcheck_base.csh a
endif
$rsh $tst_remote_host_1 "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; $DSE dump -fileheader |& grep -E 'Journal State' | grep -v $expected_jnl_state ; mv cmerr_*.log cmerr_log_backup"
