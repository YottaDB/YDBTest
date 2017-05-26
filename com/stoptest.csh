#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Invoking this script from,
# /testarea1/kishoreh/tst_V990_dbg_15_130207_212156/ideminter_rolrec_0/tmp	- Stops the current subtest
# /testarea1/kishoreh/tst_V990_dbg_15_130207_212156/ideminter_rolrec_0/		- Stops the current test i.e ideminter_rolrec
# /testarea1/kishoreh/tst_V990_dbg_15_130207_212156/				- Stops the complete test run

if !($?gtm_tst) setenv gtm_tst $gtm_test/T990
source $gtm_tst/com/set_specific.csh

set submit_pid = ""
set submit_test_pid = ""
set instream_pid = ""
set submit_subtest_pid = ""
set subtest_pid = ""
set submit_test_children = ""
if ("HP-UX" == "$HOSTOS") then
	set pspid = "ps -xfp"	#BYPASSOK ps
else
	set pspid = "ps -fp"	#BYPASSOK ps
endif

if (-e PID) then
	# If PID found in pwd, then stop the entire test
	set submit_pid = `$tst_awk '{print $NF}' PID`
	set stopall = 1
	set configfile = "config.log"
else if (-e ../PID) then
	# If PID is found in pwd ../ then stop the current test
	set submit_pid = `$tst_awk '{print $NF}' ../PID`
	set stoptest = 1
	$grep $cwd:t ../report.txt >&! /dev/null
	if !($status) then
		echo "# The test $cwd:t has already completed. Exiting now"
		exit 1
	endif
	set configfile = "config.log"
else if ( -e ../../PID) then
	# If PID is found in pwd ../../ then stop the current subtest
	set submit_pid = `$tst_awk '{print $NF}' ../../PID`
	# If submit_subtest scheme is not in this test, then consider it a stop test scenario
	if (-e ../timing.subtest) then
		set stopsubtest = 1
	else
		set stoptest = 1
	endif
	$grep $cwd:h:t ../../report.txt >&! /dev/null
	if !($status) then
		echo "#The test $cwd:h:t has already completed. Exiting now"
		exit 1
	endif
	set configfile = "../config.log"
else
	if ( (-e primary_dir) || (-e ../primary_dir) || (-e ../../primary_dir) ) then
		echo "# This is REMOTE directory. Please run from the PRIMARY directory"
	else
		echo "# PID file not found. Please make sure you are in the correct directory"
	endif
	exit
endif
$grep -E "REMOTE HOSTS|GT.CM SERVERS" $configfile >&! /dev/null
if !($status) set warn_remote = 1

if ("" != "$submit_pid") then
	echo "submit.csh PID is: $submit_pid"
	set submit_test_pid = `ps -lef| $tst_awk -f $gtm_tst/com/stoptest.awk -v thepid=$submit_pid`	#BYPASSOK
endif

if ("" != "$submit_test_pid") then
	echo "submit_test PID is:" $submit_test_pid
	set instream_pid = `ps -lef | $tst_awk -f $gtm_tst/com/stoptest.awk -v thepid=$submit_test_pid`	#BYPASSOK
	# submit_test.csh now submits a background watchdog process too. Make sure the pid is of instream.csh
	foreach pid ($instream_pid)
		$pspid $pid |& cat |& grep '/instream' >&! /dev/null	#BYPASSOK ps	pipe to cat shows untruncated output on some platforms
		if !($status) then
			set real_instream = $pid
		else
			set submit_test_children = "$submit_test_children $pid"
		endif
	end
	if !($?real_instream) then
		echo "unable to find instream.csh PID from submit_test PID above. Will exit now"
		exit 1
	endif
	set instream_pid = $real_instream

endif

if ($?stopsubtest) then
	if ("" != "$instream_pid") then
		echo "instream.csh PID is:" $instream_pid
		set submit_subtest_pid = `ps -lef | $tst_awk -f $gtm_tst/com/stoptest.awk -v thepid=$instream_pid`	#BYPASSOK
	endif

	if ("" != "$submit_subtest_pid") then
		echo "submit_subtest PID is : $submit_subtest_pid"
		set subtest_pid = `ps -lef | $tst_awk -f $gtm_tst/com/stoptest.awk -v thepid=$submit_subtest_pid`	#BYPASSOK
	endif

	if ("" != "$subtest_pid") then
		echo "subtest PID is : $subtest_pid"
	endif
endif

if ($?stopall) then
	echo "# Stopping the entire test run"
	echo "kill -9 $submit_pid (submit.csh)"
	/bin/kill -9 $submit_pid
	echo "kill -9 $submit_test_pid (submit_test.csh) $submit_test_children"
	/bin/kill -9 $submit_test_pid $submit_test_children
endif

if ( ($?stopall) || ($?stoptest) ) then
	echo "# Kill all children of $instream_pid (instream.csh) , then kill $instream_pid"
	echo "# Stopping instream.csh:  kill -STOP $instream_pid"
	/bin/kill -STOP $instream_pid
	set killchildrenof = $instream_pid
endif

if ($?stopsubtest) then
	echo "# Kill all children of $subtest_pid (subtest), then kill $subtest_pid"
	echo "# Stopping subtest : kill -STOP $subtest_pid"
	/bin/kill -STOP $subtest_pid
	set killchildrenof = $subtest_pid
endif

set finish = 0

while !($finish)
	set list = `ps -lef | $grep -v -E "defunct|zombie" | $tst_awk -f  $gtm_tst/com/stoptest.awk -v thepid=$killchildrenof -v find_children=1`	#BYPASSOK
	if ("$list" != "") then
		echo "kill all children:" $list
		/bin/kill -9 $list
	else
		set finish=1
	endif
end

set pridir = $cwd
set secdir = `$gtm_tst/com/flip.csh echo`
if ("" == "$secdir") then
	set dircheck = "$pridir"
else
	set dircheck = "$pridir|$secdir"
endif

set other_processes = `$lsof | $grep -E "$dircheck" |& $tst_awk '{if ($1 ~ /dse|mumps|mupip|gdb|dbx|gtcm/) print $2}'  | sort -u`
while ("" != "$other_processes")
	echo "kill -15 $other_processes (mumps/mupip/dse process)"
	/bin/kill -15 $other_processes
	foreach pid ($other_processes)
		$gtm_tst/com/is_proc_alive.csh $pid
		if ($status) continue
		echo "kill $pid (mumps/mupip/dse process)"
		/bin/kill -9 $pid
		$gtm_tst/com/wait_for_proc_to_die.csh $pid 30 "" "nolog"
		if ($status) then
			echo "*** Cannot kill $pid. Will stop trying to kill other gtm processes ***"
			set exit_other_processes = 1
			break
		endif
	end
	set other_processes = `$lsof | $grep -E "$dircheck" |& $tst_awk '{if ($1 ~ /dse|mumps|mupip|gdb|dbx|gtcm/) print $2}'  | sort -u`
	if ($?exit_other_processes) break
end

echo "kill the stopped $killchildrenof now"
/bin/kill -9 $killchildrenof

echo "# These ipcs might be related to the test stopped..."
$gtm_tst/com/ipcs | $grep $USER

if ($?warn_remote) then
	echo "# Do not forget to cleanup processes in the remote host"
	$grep -E "REMOTE HOSTS|GT.CM SERVERS" $configfile
endif
