#################################################################
#								#
# Copyright (c) 2021-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test for issue YDBGo#34 tests the new yottadb.RegisterSignalNotify() and
# yottadb.UnRegisterSignalNotify() to provide user handling for some of the signals
# that YottaDB sets up handlers for. Specifically, this test does not test the handling
# of the SIGALARM or SIGURG signals - both because they occur naturally so the test
# cannot tell why these signals pop when they were not requested. One (SIGURG) seems
# to occur almost constantly so is not possible to test.
#
# The ydbgo34a test is first and runs $MAXITER times (set below) choosing a random signal
# each time to test. The test sets up a "success" handler for the chosen signal and a
# "wrong handler - fail" handler for all other signals that it tests so if the wrong handler
# is driven, the test sees it.
#
# This first test also starts up 4 goroutines that are spinning hard doing increments of
# various globals so something is busy in the background simplistically simulating an actual
# application. The chosen signal is then sent to the process. We record the output, then we run
# an awk-ish "scrubber" on the file to remove output lines that differ amongst the various signals
# to make the reference file uniform for all signals and to turn the signal names to a common
# name for reference file purposes. The lines that are left should be enough to identify that a
# problem exists but in test directory where this all happens is a file called
# ydbgo34a.outx file there that has the unfiltered output of each of the runs as well for
# debugging purposes.
#
setenv MAXITER 20 # Number of times to run the randomized signal test routine (ydbgo34a)
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out || \
	echo "# dbcreate failed. Output of dbcreate.out follows" && cat dbcreate.out
#
# Set up the golang environment and sets up our repo
#
# Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $ydbgo_url, $goflags)
source $gtm_tst/com/setupgoenv.csh >& setupgoenv.out || \
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status]:" && cat setupgoenv.out && exit 1

# Build our routine (must be built due to use of cgo).
echo "# Building ydbgo34a"
$gobuild $gtm_tst/$tst/inref/ydbgo34a.go >& go_build.log || \
	echo "TEST-E-FAILED : Unable to build ydbgo34a.go. go_build.log output follows" && cat go_build.log && exit 1

#
# Run ydbgo34a with our standard input to test RegisterSignalNotify() and save the output
#
$echoline
echo "# Running ydbgo34a $MAXITER times to test yottadb.RegisterSignalNotify() - Any errors show below"
echo "#"
@ cnt = $MAXITER
while (0 < $cnt)
	# Note ydbgo34a.outxcur, ydbgo34a.outxtxt and ydbgo34a.diff are re-created on each iteration.
	`pwd`/ydbgo34a >& ydbgo34a.outxcur
	@ cnt = $cnt - 1
	@ runnum = $MAXITER - $cnt
	# Process each run separately so this M program can read which signal was used above and use to restrict
	# what KILLBYSIG messages we suppress (don't want to suppress cores we weren't expecting).
	$ydb_dist/yottadb -run ydbgo34 < ydbgo34a.outxcur >& ydbgo34a.outxtxt
	$gtm_tst/com/wait_for_proc_to_die.csh `cat ydbgo34a.pid`
	$ydb_dist/mupip rundown -reg DEFAULT >& ydbgo34a_mupip_rundown_run${runnum}.log
	$ydb_dist/mupip integ -reg DEFAULT >& ydbgo34a_mupip_integ_run${runnum}.log
	# Check our output file against ydbgo34a.txt reference file. If pass, go on without adding anything to
	# our reference output. If it fails, put both the unaltered output and the diff file in the reference output.
	diff -bcw $gtm_tst/$tst/outref/ydbgo34a.txt ydbgo34a.outxtxt > ydbgo34a.diff
	if (0 != $status) then
		$echoline
		echo "Test fail in run #" $runnum
		$echoline
		cat ydbgo34a.outxcur
		$echoline
		cat ydbgo34a.diff
		$echoline
		echo
	endif
	# Keep a grand total of all the runs separately for debugging purposes
	cat ydbgo34a.outxcur >> ydbgo34a.outx
	echo "--------------------------------------------------------------------------------" >> ydbgo34a.outx
	echo >> ydbgo34a.outx
end
$echoline
#
# And now setup ydbgo34b to test yottadb.UnRegisterSignalNotify()
#
echo "# Run ydbgo34b to test to test yottadb.UnRegisterSignalNotify(). This is done by sending a simple"
echo "# signal 3 times: (1) no handler set, (2) set a handler, (3) unset that handler."
echo "# Building ydbgo34b"
echo >> go_build.log
echo >> go_build.log
$gobuild $gtm_tst/$tst/inref/ydbgo34b.go >>& go_build.log || \
	echo "TEST-E-FAILED : Unable to build ydbgo34b.go. go_build.log output follows" && cat go_build.log && exit 1
echo "# Run ydbgo34b"
`pwd`/ydbgo34b
#
# Setup ydbgo34c to test when yottadb.RegisterSignalNotify() is passed an unsupported signal
#
echo
$echoline
echo "# Run ydbgo34c to test passing an unsupported signal to yottadb.RegisterSignalNotify()"
echo "# Building ydbgo34c"
echo >> go_build.log
echo >> go_build.log
$gobuild $gtm_tst/$tst/inref/ydbgo34c.go >>& go_build.log || \
	echo "TEST-E-FAILED : Unable to build ydbgo34c.go. go_build.log output follows" && cat go_build.log && exit 1
echo "# Run ydbgo34c - expect each of 5 errors to be doubled - once for each of RegisterSignalNotify() and UnRegisterSignalNotify()"
`pwd`/ydbgo34c
#
# Setup ydbgo34d to test that wait timeout and syslogEntry() routine both work correctly. This test creates a situation where
# there is a notification handler for a signal (SIGILL this time), that runs and then sleeps until the signal acknowledgement
# timer (yottadb.MaximumSigAckWait) expires to drive the message then exits cleanly.
#
echo
$echoline
echo "# Run ydbgo34d to test wait timeout for signal acknowledgement and test syslogEntry() routine is working by forcing a"
echo "# syslog entry and waiting for it."
echo "# Building ydbgo34d"
echo >> go_build.log
echo >> go_build.log
$gobuild $gtm_tst/$tst/inref/ydbgo34d.go >>& go_build.log || \
	echo "TEST-E-FAILED : Unable to build ydbgo34d.go. go_build.log output follows" && cat go_build.log && exit 1
echo "# Run ydbgo34d - will run for about 10 seconds (length of internal wait)"
set syslog_before = `date +"%b %e %H:%M:%S"`
`pwd`/ydbgo34d
set pid = `cat pid.txt`
# Now find out if the error made it to the syslog
echo "# Expected syslog entry shown below"
$gtm_tst/com/getoper.csh "$syslog_before" "" syslog1.txt "" "$pid.*YDB-E-SIGACKTIMEOUT"
$grep "$pid.*SIGACKTIMEOUT" syslog1.txt
#
# All done - Validate DB
#
echo
$echoline
echo "# Validate DB"
unsetenv ydb_gbldir
$gtm_tst/com/dbcheck.csh
