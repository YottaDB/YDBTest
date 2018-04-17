#! /usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

@ rand = `$gtm_exe/mumps -run rand 2`
if ($rand) then
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_error_on_jnl_file_lost gtm_error_on_jnl_file_lost "1"
	set expected_jnl_state = "ON"
else
	set expected_jnl_state = "OFF"
endif

# This test validate that all call to cre_jnl_file() handle failures.
# It uses white box testing to ensure that cre_jnl_file() always return EXIT_ERR.
echo "Testing C9C04001977"
echo "On error, journaling should be $expected_jnl_state"

# Handy aliases
alias dump_file_header '$DSE dump -fileheader |& $grep -E "Journal State" | $grep -v \!:1'
alias check_jnl_state 'echo "** Checking journaling state **" ; dump_file_header \!:1'

alias disable_wb 'unsetenv gtm_white_box_test_case_enable ; unset gtm_white_box_test_case_number'
alias enable_wb 'setenv gtm_white_box_test_case_number 42 ; setenv gtm_white_box_test_case_enable 1'

alias start_test '$MUPIP set -journal=disable -reg DEFAULT >& start_test_disable_\!{:1}.outx ; rm mumps.mjl* >& start_test_rm_\!{:1}.outx ; $MUPIP set -journal=enable,on,before,autoswitchlimit=16384 -reg DEFAULT |& tee start_test_enable_\!{:1}.outx; $gtm_exe/mumps -run %XCMD "set ^a=1" |& tee start_test_write_\!{:1}.outx; echo "** Ready to run test."'
alias start_test_replic 'start_test \!{:1} ; set instname=\!{:1} ; setenv gtm_repl_instance ${instname}.inst ; $MUPIP replicate -instance_create -name=${instname} $gtm_test_qdbrundown_parms >& start_test_replic_mkinst_\!{:1}.out ; $MUPIP set -replic=on -reg DEFAULT >& start_test_replic_on_\!{:1}.out ; $MUPIP replicate -source -start -passive -log=SRC_${instname}_\!{:1}.logx -instsecondary=${instname}2 -rootprimary >& start_test_replic_startsrc_\!{:1}.out'
alias stop_test_replic '$MUPIP replicate -source -shutdown -timeout=0 >& stop_test_replic_\!{:1}.out'

# Create database
setenv gtm_test_freeze_on_error 0	# Known initial state
$gtm_tst/com/dbcreate.csh mumps

###
echo "** Testing for sr_port/mupip_set_journal.c"

start_test msj
enable_wb
$MUPIP set -journal=enable,on,before,autoswitchlimit=16384 -reg DEFAULT
disable_wb
$gtm_exe/mumps -run %XCMD 'set ^a="sr_port/mupip_set_journal.c"'
check_jnl_state ON

###
echo "** Testing for sr_port/mupip_backup.c"

start_test mb
enable_wb
$MUPIP backup -newjnlfiles -online DEFAULT bkup |& $grep JNLNOCREATE
disable_wb
$gtm_exe/mumps -run %XCMD 'set ^a="sr_port/mupip_backup.c"'
check_jnl_state ON

###
echo "** Testing for sr_port/jnl_file_open_switch.c"

set syslog_begin = `date +"%b %e %H:%M:%S"`
start_test jfos
enable_wb
# corrupt journal file so jnl_file_open_switch is called.
echo 'deadbeef' | cat - mumps.mjl > mumps.mjl_corrupted
cp mumps.mjl mumps.mjl_orig
cp mumps.mjl_corrupted mumps.mjl
$MUPIP extend DEFAULT >& jfos_extend.outx
$grep MUNOACTION jfos_extend.outx
set syslog_after = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_after" syslog_jnl_file_open_switch.txt "" "JNLSWITCHFAIL"
# fix journal file
cp mumps.mjl_orig mumps.mjl
disable_wb
$gtm_exe/mumps -run %XCMD 'set ^a="sr_port/jnl_file_open_switch.c"'
check_jnl_state ON

###
echo "** Testing for sr_port/mur_process_intrpt_recov.c"

start_test mpir
# The kill -9 done below can hit the process at the midst of wcs_wtstart in which case the # of dirty buffer and the active queue
# will be out-of-sync in the shared memory. This would result in the subsequent journal recovery to assert fail in wcs_flu. To
# workaround the assert, white box test case 29 (WBTEST_CRASH_SHUTDOWN_EXPECTED) needs to be defined. However, the test already
# defines WBTEST_JNL_CREATE_FAIL. So, do a 'dse buff' to ensure all the dirty buffers are written to disk before proceeding with
# the kill -9. This way the shared memory information will be in sync with respect to the dirty buffers and active queue.
#
$GTM << EOF
set ^a=123
zsystem "$gtm_exe/dse buff >&! dsebuff.out"
zsystem "$kill9 "_\$job
EOF
enable_wb
$MUPIP journal -recover -backward mumps.mjl |& $grep JNLNOCREATE
disable_wb
$MUPIP journal -recover -backward mumps.mjl >& /dev/null
$gtm_exe/mumps -run %XCMD 'set ^a="sr_port/mur_process_intrpt_recov.c"'
check_jnl_state ON

###
echo "** Testing for sr_unix/jnl_file_extend.c"

start_test jfe
enable_wb
set syslog_before = `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run %XCMD 'for i=1:1:200000 set ^b=i' >& jnl_file_extend.outx
set syslog_after = `date +"%b %e %H:%M:%S"`
disable_wb
$gtm_exe/mumps -run %XCMD 'set ^a="sr_unix/jnl_file_extend.c"'
if ("OFF" == $expected_jnl_state) then  # JNLNOCREATE will be sent to syslog only with the default journal error behaviour
	$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog_jnl_file_extend.txt "" JNLNOCREATE
endif
check_jnl_state $expected_jnl_state

###
echo "** Testing for sr_unix/jnl_file_extend.c (empty custom errors, -noinst_freeze_on_error)"

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_custom_errors gtm_custom_errors "/dev/null"
unsetenv gtm_test_fake_enospc
source $gtm_tst/com/unset_ydb_env_var.csh ydb_error_on_jnl_file_lost gtm_error_on_jnl_file_lost
start_test_replic jfe_ece
enable_wb
set syslog_before = `date +"%b %e %H:%M:%S"`
sleep 1		# Make sure everything is in the syslog
$gtm_exe/mumps -run %XCMD 'for i=1:1:200000 set ^b=i' >& jnl_file_extend_${instname}.out
set syslog_after = `date +"%b %e %H:%M:%S"`
disable_wb
$gtm_exe/mumps -run %XCMD 'set ^a="sr_unix/jnl_file_extend.c (empty custom errors, -noinst_freeze_on_error)"'
$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog_jnl_file_extend_${instname}.txt "" JNLNOCREATE
check_jnl_state OFF
stop_test_replic ${instname}

###
echo "** Testing for sr_unix/jnl_file_extend.c (default custom errors, -noinst_freeze_on_error)"

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_custom_errors gtm_custom_errors "$gtm_tools/custom_errors_sample.txt"
unsetenv gtm_test_fake_enospc
source $gtm_tst/com/unset_ydb_env_var.csh ydb_error_on_jnl_file_lost gtm_error_on_jnl_file_lost
start_test_replic jfe_dce
enable_wb
set syslog_before = `date +"%b %e %H:%M:%S"`
sleep 1		# Make sure everything is in the syslog
$gtm_exe/mumps -run %XCMD 'for i=1:1:200000 set ^b=i' >& jnl_file_extend_${instname}.out
set syslog_after = `date +"%b %e %H:%M:%S"`
disable_wb
$gtm_exe/mumps -run %XCMD 'set ^a="sr_unix/jnl_file_extend.c (empty custom errors, -noinst_freeze_on_error)"'
$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog_jnl_file_extend_${instname}.txt "" JNLNOCREATE
check_jnl_state OFF
stop_test_replic ${instname}

###
echo "** Testing for sr_unix/jnl_file_extend.c (empty custom errors, -inst_freeze_on_error)"

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_custom_errors gtm_custom_errors "/dev/null"
unsetenv gtm_test_fake_enospc
source $gtm_tst/com/unset_ydb_env_var.csh ydb_error_on_jnl_file_lost gtm_error_on_jnl_file_lost
start_test_replic jfe_ece_ifoe
$MUPIP set -inst_freeze_on_error -region DEFAULT >& set_ifoe_${instname}.out
enable_wb
set syslog_before = `date +"%b %e %H:%M:%S"`
sleep 1		# Make sure everything is in the syslog
$gtm_exe/mumps -run %XCMD 'for i=1:1:200000 set ^b=i' >& jnl_file_extend_${instname}.out
set syslog_after = `date +"%b %e %H:%M:%S"`
disable_wb
$gtm_exe/mumps -run %XCMD 'set ^a="sr_unix/jnl_file_extend.c (empty custom errors, -noinst_freeze_on_error)"'
$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog_jnl_file_extend_${instname}.txt "" JNLNOCREATE
check_jnl_state OFF
stop_test_replic ${instname}

###
echo "** Testing for sr_unix/jnl_file_extend.c (default custom errors, -inst_freeze_on_error)"

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_custom_errors gtm_custom_errors "$gtm_tools/custom_errors_sample.txt"
unsetenv gtm_test_fake_enospc
source $gtm_tst/com/unset_ydb_env_var.csh ydb_error_on_jnl_file_lost gtm_error_on_jnl_file_lost
start_test_replic jfe_dce_ifoe
$MUPIP set -inst_freeze_on_error -region DEFAULT >& set_ifoe_${instname}.out
enable_wb
set syslog_before = `date +"%b %e %H:%M:%S"`
sleep 1		# Make sure everything is in the syslog
$gtm_exe/mumps -run %XCMD 'for i=1:1:200000 set ^b=i' >& jnl_file_extend_${instname}.out
set syslog_after = `date +"%b %e %H:%M:%S"`
disable_wb
$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog_jnl_file_extend_${instname}.txt "" JNLNOCREATE
$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" syslog_jnl_file_extend_${instname}.txt "" REPLINSTFROZEN
check_jnl_state ON
$MUPIP replic -source -freeze=off
$gtm_exe/mumps -run %XCMD 'set ^a="sr_unix/jnl_file_extend.c (empty custom errors, -noinst_freeze_on_error)"'
stop_test_replic ${instname}
$gtm_tst/com/check_error_exist.csh jnl_file_extend_${instname}.out JNLEXTEND JNLNOCREATE

$gtm_tst/com/dbcheck.csh
