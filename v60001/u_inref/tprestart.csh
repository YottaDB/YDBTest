#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv echoline "------------------------------------------------------------------"
$gtm_tst/com/dbcreate.csh mumps 1 -allocation=2048 -extension_count=2048

echo $echoline
echo "i) gtm_tprestart_log_first and gtm_tprestart_log_delta are not defined."
@ no_of_restarts = 2
set syslog_begin = `date +"%b %e %H:%M:%S"`
echo "syslog_begin = $syslog_begin" > syslog_time1
$gtm_exe/mumps -r %XCMD "do envdelta^restart($no_of_restarts)"
@ proc_pid = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`
set syslog_end = `date +"%b %e %H:%M:%S"`
echo "syslog_end = $syslog_end" >> syslog_time1
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_end" test_syslog1.txt
@ act_msgcnt = `$grep -c "${proc_pid}.*YDB-I-TPRESTART" test_syslog1.txt`
if (0 == $act_msgcnt) then
	echo "No message is seen in the operator log"
else
	echo "TEST-E-FAIL: TPRESTART message seen in the operator log"
	echo "ACTUAL MESSAGE COUNT=$act_msgcnt	EXPECTED MESSAGE COUNT=0"
endif

echo $echoline
echo "ii) Only gtm_tprestart_log_first is defined."
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tprestart_log_first gtm_tprestart_log_first 3
@ no_of_restarts = 2
set syslog_begin = `date +"%b %e %H:%M:%S"`
echo "syslog_begin = $syslog_begin" > syslog_time2
$gtm_exe/mumps -r %XCMD "do envdelta^restart($no_of_restarts)"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_tprestart_log_first gtm_tprestart_log_first
@ proc_pid = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`
set syslog_end = `date +"%b %e %H:%M:%S"`
echo "syslog_end = $syslog_end" >> syslog_time2
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_end" test_syslog2.txt
@ act_msgcnt = `$grep -c "${proc_pid}.*YDB-I-TPRESTART.*in glbl: \^a([0-9]*)" test_syslog2.txt`
if (0 == $act_msgcnt) then
	echo "No message is seen in the operator log"
else
	echo "TEST-E-FAIL: TPRESTART message seen in the operator log"
	echo "ACTUAL MESSAGE COUNT=$act_msgcnt	EXPECTED MESSAGE COUNT=0"
endif

echo $echoline
echo "iii) Only gtm_tprestart_log_delta is defined."
set delta = 3
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tprestart_log_delta gtm_tprestart_log_delta $delta
@ no_of_restarts = 20
@ exp_msgcnt = $no_of_restarts / $delta
set syslog_begin = `date +"%b %e %H:%M:%S"`
echo "syslog_begin = $syslog_begin" > syslog_time3
$gtm_exe/mumps -r %XCMD "do envdelta^restart($no_of_restarts)"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_tprestart_log_delta gtm_tprestart_log_delta
@ proc_pid = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`
set syslog_end = `date +"%b %e %H:%M:%S"`
echo "syslog_end = $syslog_end" >> syslog_time3
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_end" test_syslog3.txt "" "${proc_pid}.*YDB-I-TPRESTART.*in glbl: \^a([0-9]*)" $exp_msgcnt
if (0 == $status) then
	echo "no of messages = $exp_msgcnt"
else
	echo "TEST-E-FAIL: Unexpected no of messages seen in the operator log. See test_syslog3.txt."
endif

echo $echoline
echo "iv) gtm_tprestart_log_first and gtm_tprestart_log_delta both are defined."
set delta = 3
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tprestart_log_delta gtm_tprestart_log_delta $delta
set first = 4
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tprestart_log_first gtm_tprestart_log_first $first
@ no_of_restarts = 20
@ exp_msgcnt = ($no_of_restarts - $first) / $delta
@ exp_msgcnt = $exp_msgcnt + $first
set syslog_begin = `date +"%b %e %H:%M:%S"`
echo "syslog_begin = $syslog_begin" > syslog_time4
$gtm_exe/mumps -r %XCMD "do envdelta^restart($no_of_restarts)"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_tprestart_log_delta gtm_tprestart_log_delta
source $gtm_tst/com/unset_ydb_env_var.csh ydb_tprestart_log_first gtm_tprestart_log_first
@ proc_pid = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`
set syslog_end = `date +"%b %e %H:%M:%S"`
echo "syslog_end = $syslog_end" >> syslog_time4
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_end" test_syslog4.txt "" "${proc_pid}.*YDB-I-TPRESTART.*in glbl: \^a([0-9]*)" $exp_msgcnt
if (0 == $status) then
	echo "no of messages = $exp_msgcnt"
else
	echo "TEST-E-FAIL: Unexpected no of messages seen in the operator log. See test_syslog4.txt."
endif

echo $echoline
echo "v) gtm_tprestart_log_delta is not specified and VIEW command also did specify the value for logging frequency."
# Default value for the logging frequency is 1
@ no_of_restarts = 3
@ exp_msgcnt = $no_of_restarts
set syslog_begin = `date +"%b %e %H:%M:%S"`
echo "syslog_begin = $syslog_begin" > syslog_time5
$gtm_exe/mumps -r %XCMD "do viewdelta^restart($no_of_restarts,0,100)"
@ proc_pid = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`
set syslog_end = `date +"%b %e %H:%M:%S"`
echo "syslog_end = $syslog_end" >> syslog_time5
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_end" test_syslog5.txt "" "${proc_pid}.*YDB-I-TPRESTART.*in glbl: \^a([0-9]*)" $exp_msgcnt
if (0 == $status) then
	echo "no of messages = $exp_msgcnt"
else
	echo "TEST-E-FAIL: Unexpected no of messages seen in the operator log. See test_syslog5.txt."
endif

echo $echoline
echo "vi) gtm_tprestart_log_delta is not specified but VIEW command specified the value for logging frequency."
@ log_freq = 3
@ no_of_restarts = 20
@ exp_msgcnt = $no_of_restarts / $log_freq
set syslog_begin = `date +"%b %e %H:%M:%S"`
echo "syslog_begin = $syslog_begin" > syslog_time6
$gtm_exe/mumps -r %XCMD "do viewdelta^restart($no_of_restarts,1,$log_freq)"
@ proc_pid = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`
set syslog_end = `date +"%b %e %H:%M:%S"`
echo "syslog_end = $syslog_end" >> syslog_time6
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_end" test_syslog6.txt "" "${proc_pid}.*YDB-I-TPRESTART.*in glbl: \^a([0-9]*)" $exp_msgcnt
if (0 == $status) then
	echo "no of messages = $exp_msgcnt"
else
	echo "TEST-E-FAIL: Unexpected no of messages seen in the operator log. See test_syslog6.txt."
endif

echo $echoline
echo "vii) gtm_tprestart_log_delta is specified but VIEW command did not specify the value for logging frequency."
set delta = 3
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tprestart_log_delta gtm_tprestart_log_delta $delta
@ no_of_restarts = 20
@ exp_msgcnt = $no_of_restarts / $delta
set syslog_begin = `date +"%b %e %H:%M:%S"`
echo "syslog_begin = $syslog_begin" > syslog_time7
$gtm_exe/mumps -r %XCMD "do viewdelta^restart($no_of_restarts,0,100)"
@ proc_pid = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`
set syslog_end = `date +"%b %e %H:%M:%S"`
echo "syslog_end = $syslog_end" >> syslog_time7
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_end" test_syslog7.txt "" "${proc_pid}.*YDB-I-TPRESTART.*in glbl: \^a([0-9]*)" $exp_msgcnt
if (0 == $status) then
	echo "no of messages = $exp_msgcnt"
else
	echo "TEST-E-FAIL: Unexpected no of messages seen in the operator log. See test_syslog7.txt."
endif

echo $echoline
echo "viii) gtm_tprestart_log_delta is specified and VIEW command specified the value for tprestart logging frequency."
set delta = 3
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tprestart_log_delta gtm_tprestart_log_delta $delta
@ log_freq = 9
@ no_of_restarts = 20
@ exp_msgcnt = $no_of_restarts / $log_freq
set syslog_begin = `date +"%b %e %H:%M:%S"`
echo "syslog_begin = $syslog_begin" > syslog_time8
$gtm_exe/mumps -r %XCMD "do viewdelta^restart($no_of_restarts,1,$log_freq)"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_tprestart_log_delta gtm_tprestart_log_delta
@ proc_pid = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`
set syslog_end = `date +"%b %e %H:%M:%S"`
echo "syslog_end = $syslog_end" >> syslog_time8
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_end" test_syslog8.txt "" "${proc_pid}.*YDB-I-TPRESTART.*in glbl: \^a([0-9]*)" $exp_msgcnt
if (0 == $status) then
	echo "no of messages = $exp_msgcnt"
else
	echo "TEST-E-FAIL: Unexpected no of messages seen in the operator log. See test_syslog8.txt."
endif

echo $echoline
echo "ix) Negative value for the LOGTPRESTART is specified."
set delta = 3
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tprestart_log_delta gtm_tprestart_log_delta $delta
@ log_freq = -5
@ no_of_restarts = 5
@ exp_msgcnt = 0
set syslog_begin = `date +"%b %e %H:%M:%S"`
echo "syslog_begin = $syslog_begin" > syslog_time9
$gtm_exe/mumps -r %XCMD "do viewdelta^restart($no_of_restarts,1,$log_freq)"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_tprestart_log_delta gtm_tprestart_log_delta
@ proc_pid = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`
set syslog_end = `date +"%b %e %H:%M:%S"`
echo "syslog_end = $syslog_end" >> syslog_time9
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_end" test_syslog9.txt
@ act_msgcnt = `$grep -c "${proc_pid}.*YDB-I-TPRESTART" test_syslog9.txt`
if ($exp_msgcnt == $act_msgcnt) then
	echo "no of messages = $exp_msgcnt"
else
	echo "TEST-E-FAIL: Unexpected no of messages seen in the operator log."
	echo "ACTUAL MESSAGE COUNT=$act_msgcnt	EXPECTED MESSAGE COUNT=$exp_msgcnt"
endif

echo $echoline
echo "x) gtm_tprestart_log_first and gtm_tprestart_log_delta both are defined - looking for a bitmap conflict."
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
# Starting V63001A, the default GDS block size is 4K. The child^restart in v60001/inref/restart.m needs to create
# nodes whose size is greater than half the GDS block size and so uses a 3K value so use the same here for record_size.
$MUPIP set -file mumps.dat -record=3000
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tprestart_log_delta gtm_tprestart_log_delta 1
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tprestart_log_first gtm_tprestart_log_first 1
set syslog_begin = `date +"%b %e %H:%M:%S"`
echo "syslog_begin = $syslog_begin" > syslog_time10
$gtm_exe/mumps -r %XCMD "do tpbitmaprestart^restart"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_tprestart_log_delta gtm_tprestart_log_delta
source $gtm_tst/com/unset_ydb_env_var.csh ydb_tprestart_log_first gtm_tprestart_log_first
set syslog_end = `date +"%b %e %H:%M:%S"`
echo "syslog_end = $syslog_end" >> syslog_time10
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_end" test_syslog10.txt "" ".*YDB-I-TPRESTART.*BITMAP"
if (0 != $status) then
	echo "TEST-E-FAIL: not even one TPRESTART BITMAP message found"
endif

$gtm_tst/com/dbcheck.csh
