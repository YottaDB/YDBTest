#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#---------------------------------------------------------------------------------------------------------------------#"
echo '# [YDB#1090] Test that direct mode does not loop once a transaction passes the TPNOTACID retry limit                  #'
echo '# GTM-10098 in GT.M V7.1-004 makes an operation that can violate ACID properties raise a TPNOTACID error once a       #'
echo '# transaction has restarted more than 16 times by default. Direct mode checks for TPNOTACID before its prompt, so     #'
echo '# with the default $ZTRAP="B" the error would take the process back to direct mode, which would raise it again, and   #'
echo '# the process would never reach the prompt.                                                                           #'
echo '# YottaDB exempts the direct mode prompt from the limit, and sends a TPNOTACID error repeated at the same place in a  #'
echo '# transaction to the syslog only once. Each stage below restarts a transaction past the limit and verifies that:      #'
echo '#   1. a JOB, whose input is /dev/null, enters direct mode once and exits at end of file                              #'
echo '#   2. with piped input, direct mode accepts commands, and TROLLBACK ends the transaction                             #'
echo '#   3. at a terminal, direct mode accepts commands, and TROLLBACK ends the transaction                                #'
echo '#   4. a $ZTRAP that retries the failing line sends the TPNOTACID error to the syslog once, and two transactions      #'
echo '#      that each pass the limit send it once each                                                                     #'
echo "#---------------------------------------------------------------------------------------------------------------------#"
echo

# The reference file shows the TPNOTACID messages, which report the time limit and the number of restarts, so make
# sure both limits are at their defaults (16 restarts and 2000 milliseconds)
unsetenv ydb_tpnotacidtries gtm_tpnotacidtries ydb_tpnotacidtime gtm_tpnotacidtime
# If direct mode looped again, stages 1 to 3 could write errors without end. Cap the size of the files this
# subtest writes, so that a regression fails quickly instead of filling the disk.
limit filesize 100m
cp $gtm_tst/$tst/inref/tpna1090.m .

echo "# Stage 1 : JOB a process that passes the limit, with /dev/null as its input"
echo "#           expect one direct mode prompt in its .mjo, the TPNOTACID error once in its .mje, and the process to"
echo "#           end on its own after it reads end of file at the prompt"
echo "# mumps -run job^tpna1090"
$gtm_dist/mumps -run job^tpna1090
# Only errors displayed by the process are counted, not syslog messages, which go to stderr if there is no syslog.
# Only the first error is shown, since a regression would write a great many of them.
echo "# Direct mode prompts in stage1.mjo : "`$grep -c "YDB>" stage1.mjo`
echo "# TPNOTACID errors in stage1.mje    : "`$grep -c "^%YDB-E-TPNOTACID" stage1.mje`
$grep -m 1 "^%YDB-E-TPNOTACID" stage1.mje
$gtm_tst/com/check_error_exist.csh stage1.mje "TPNOTACID" >& stage1_check_error_exist.logx
echo

echo "# Stage 2 : pass the limit with direct mode reading commands from a pipe"
echo '#           expect the TPNOTACID error once, then $TLEVEL to be 1 before TROLLBACK and 0 after it'
# The input is read by direct mode, as commands typed at its prompt
echo "# mumps -run pastlimit^tpna1090, with these direct mode commands as its input :"
echo '#   write "TLEVEL=",$tlevel,!'
echo '#   trollback'
echo '#   write "TLEVEL=",$tlevel,!'
echo '#   halt'
cat << 'EOF' | timeout 60 $gtm_dist/mumps -run pastlimit^tpna1090 >& stage2.out
write "TLEVEL=",$tlevel,!
trollback
write "TLEVEL=",$tlevel,!
halt
'EOF'
if (124 == $status) echo "TEST-E-TIMEOUT, direct mode did not finish reading its commands within 60 seconds"
echo "# TPNOTACID errors in stage2.out : "`$grep -c "^%YDB-E-TPNOTACID" stage2.out`
$grep -m 1 "^%YDB-E-TPNOTACID" stage2.out
$grep -oE "TLEVEL=[0-9]+" stage2.out
$gtm_tst/com/check_error_exist.csh stage2.out "TPNOTACID" >& stage2_check_error_exist.logx
echo

echo "# Stage 3 : pass the limit with direct mode reading commands from a terminal, driven by expect"
echo '#           expect the YDB> prompt, then $TLEVEL to be 1 before TROLLBACK and 0 after it'
# The expect script keeps the spawned session quiet (log_user 0) and writes only its own result lines, since
# whether direct mode reads through readline (ydb_readline is randomized) changes how it echoes typed commands
(expect -d $gtm_tst/$tst/u_inref/tpnotacid_dmode-ydb1090.exp > stage3.exp.out) >& stage3.exp.dbg
cat stage3.exp.out
echo

echo "# Stage 4 : count the TPNOTACID errors each process sends to the syslog"
echo '#           expect 1 from ztloop, whose $ZTRAP retries the failing line 20 times, and 2 from twotp, which'
echo "#           passes the limit in two separate transactions"
set entries = (ztloop twotp)
set counts = (1 2)
foreach i (1 2)
	set entry = $entries[$i]
	set expected = $counts[$i]
	set t = `date +"%b %e %H:%M:%S"`
	# The pid is noted so that only this process's messages are counted, not those of tests running concurrently
	echo "# mumps -run $entry^tpna1090"
	($gtm_dist/mumps -run $entry^tpna1090 >& stage4_$entry.out &; echo $! >& pid_$entry.out) >& bckg_$entry.out
	set pid = `cat pid_$entry.out`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
	cat stage4_$entry.out
	$gtm_tst/com/getoper.csh "$t" "" getoper_$entry.txt "" "\[\<$pid\>\].*%YDB-E-TPNOTACID" $expected
	# Capture the syslog again before counting. With no message given, getoper.csh logs a marker message and
	# waits for it, so any message beyond the expected count has arrived by then.
	$gtm_tst/com/getoper.csh "$t" "" getoper_$entry.txt
	echo "# TPNOTACID errors in the syslog from $entry : "`$grep -c "\[\<$pid\>\].*%YDB-E-TPNOTACID" getoper_$entry.txt`
end
