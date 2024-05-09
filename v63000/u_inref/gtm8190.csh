#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1

set setglob = "setglobals.m"
set i=1
set linum = 1024
echo 'setglobals' >> $setglob
echo '	set i=0'  >> $setglob
while ($i <= $linum)
    echo '	set ^a(1)=$justify($increment(i)_$job,200) set ^b(2)=^a(1)+1 set ^c(3)=^b(2)+^a(1)' >> $setglob
    echo '	halt:^end' >> $setglob
    @ i++
end
echo '	quit' >> $setglob

echo "## ROUND 1 ##"
echo "# Use view command instead of environment variables"
setenv useviewcommand 1 # Tell children to use the view command
source $gtm_tst/com/unset_ydb_env_var.csh ydb_nontprestart_log_delta gtm_nontprestart_log_delta
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_nontprestart_log_first gtm_nontprestart_log_first

echo "# Launching processes"
set syslog_start = `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run %XCMD 'do ^gtm8190'

echo "# Waiting for all processes to start"
$gtm_tst/com/wait_for_log.csh -log pids.txt -message NONTPRESTART

set regexp = `cat pids.txt`

echo "# Looking for NONTPRESTART messages in the syslog"
# One conflict is enough
$gtm_exe/mumps -run %XCMD 'do waitrestartaction^gtm8190'
$gtm_tst/com/getoper.csh "$syslog_start" "" "syslog1.txt" "" "$regexp"

echo "# Waiting for processes to quit"
$gtm_exe/mumps -run waitpidstodie

mv pids.txt pids1.txt
mv waitpidstodie.m waitpidstodie1.m

unsetenv useviewcommand
# Setting this to maximum signed integer so that we can control the number of messsages by setting gtm_nontprestart_log_first only
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_nontprestart_log_delta gtm_nontprestart_log_delta 2147483647
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_nontprestart_log_first gtm_nontprestart_log_first 1

# This round is necessary because we want to capture a fixed number of NONTPRESTART messages in the outref. Round 2 does not capture
# the whole message in the outref
echo "## ROUND 2 ##"
echo "# Run with gtm_nontprestart_log_first = 1 to confirm each process generates only 1 message"

echo "# Launching processes"
set syslog_start = `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run gtm8190

echo "# Waiting for all processes to start"
$gtm_tst/com/wait_for_log.csh -log pids.txt -message NONTPRESTART

echo "# Show the messages"
set regexp=`cat pids.txt`

# There are 3 processes each of which can issue at most 1 message
$gtm_tst/com/getoper.csh "$syslog_start" "" "syslog2.txt" "" "$regexp" 3

$gtm_tst/com/check_error_exist.csh syslog2.txt NONTPRESTART

# The following grep should not find code L and 0 block number at the same time
$grep -q 'code: [^L]*L[^;]*; blk: 0x0000000000000000' syslog2.txtx
if (0 == $status) then
    echo "TEST-E-FAIL The block number can not be 0 if the error code is L. See syslog2.txtx"
endif

$gtm_exe/mumps -run %XCMD "set ^end=1"

echo "# Waiting for processes to quit"
$gtm_exe/mumps -run waitpidstodie

mv pids.txt pids2.txt
mv waitpidstodie.m waitpidstodie2.m
$gtm_tst/com/backup_dbjnl.csh "round2jobdir" "*mjo* *mje*" mv nozip

if (! $?random_gtm_nontprestart_log_first) then
	# Choose a random number between [1,10]
	setenv random_gtm_nontprestart_log_first `$gtm_exe/mumps -run rand 10 1 0`
	echo "setenv random_gtm_nontprestart_log_first $random_gtm_nontprestart_log_first" >> settings.csh
endif

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_nontprestart_log_first gtm_nontprestart_log_first $random_gtm_nontprestart_log_first

echo "## ROUND 3 ##"
echo "# Randomly select gtm_nontprestart_log_first and make sure each process generates chosen number of messages"

echo "# Launching processes"
set syslog_start = `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run gtm8190

echo "# Waiting for all processes to start"
$gtm_tst/com/wait_for_log.csh -log pids.txt -message NONTPRESTART

set regexp=`cat pids.txt`

# There are 3 processes each of which can issue at most $random_gtm_nontprestart_log_first messages
set msgcount = `expr 3 \* $random_gtm_nontprestart_log_first`

echo "# Looking for NONTPRESTART messages in the syslog"
if ($random_gtm_nontprestart_log_first > 0) then
	$gtm_tst/com/getoper.csh "$syslog_start" "" "syslog3.txt" "" "$regexp" $msgcount
	if ($status) then
		$grep 'last message repeated' syslog3.txt
		if (0 == $status) then
			echo "TEST-I-PERHAPS-PASS THE TEST MAY HAVE PASSED!"
			echo "It appears that syslog truncated some of the NONTPRESTART messages (see above)."
			echo "Please examine syslog3.txt, add the truncated NONTPRESTART messages above the line shown above. If the total is $msgcount this test has passed."
		endif
	endif
else
	sleep 5 # Give a chance for messages to trigger
	$gtm_tst/com/getoper.csh "$syslog_start" "" "syslog3.txt" ""
endif

if ($msgcount < `$grep -c -E "$regexp" syslog3.txt`) then
	echo "TEST-E-FAIL too many messages. Check syslog3.txt"
endif

$gtm_exe/mumps -run %XCMD "set ^end=1"

echo "# Waiting for processes to quit"
$gtm_exe/mumps -run waitpidstodie

mv pids.txt pids3.txt
mv waitpidstodie.m waitpidstodie3.m

$gtm_tst/com/dbcheck.csh
