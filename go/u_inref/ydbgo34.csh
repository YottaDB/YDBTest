#################################################################
#								#
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
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
# problem exists but in the go/src/ydbgo34a directory where this all happens is a file called
# ydbgo34a.outx file there that has the unfiltered output of each of the runs as well for
# debugging purposes.
#
# This test tests intercepting SIGHUP so for that to happen, we have to enable SIGHUP processing
setenv ydb_hupenable TRUE
#
setenv MAXITER 20 # Number of times to run the randomized signal test routine (ydbgo34a)
$gtm_tst/com/dbcreate.csh mumps -gld_has_db_fullpath >>& dbcreate.out
if ($status) then
        echo "# dbcreate failed. Output of dbcreate.out follows"
        cat dbcreate.out
endif
#
# Set up the golang environment and sets up our repo
#
source $gtm_tst/com/setupgoenv.csh # Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $go_repo)
set status1 = $status
if ($status1) then
	echo "[source $gtm_tst/$tst/u_inref/setupgoenv.csh] failed with status [$status1]. Exiting..."
	exit 1
endif

cd go/src
mkdir ydbgo34a
cd ydbgo34a
ln -s $gtm_tst/$tst/inref/ydbgo34a.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link ydbgo34a.go to current directory ($PWD)"
    exit 1
endif
# Build our routine (must be built due to use of cgo).
echo "# Building ydbgo34a"
$gobuild >& go_build.log
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build ydbgo34a.go. go_build.log output follows"
    cat go_build.log
    exit 1
endif
#
# Note: We need to set the global directory to an absolute path because we are operating in a subdirectory
# ($tstpath/go/src/ydbgo34) where the default test framework assignment of ydb_gbldir
# to a relative path (i.e. mumps.gld) is no longer relevant.
setenv ydb_gbldir $tstpath/mumps.gld
# Set WBTEST_CRASH_SHUTDOWN_EXPECTED to avoid assert from wcs_flu(). This test intentionally drives signals against
# running processes but with Go, the threads in these processes sometimes are killed when in the middle of commits
# followed by a MUPIP INTEG. This can leave buffers in shared memory so we set the white box test case to avoid
# asserts in wcs_flu.c
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29

#
# Run ydbgo34a with our standard input to test RegisterSignalNotify() and save the output
#
$echoline
echo "# Running ydbgo34a $MAXITER times to test yottadb.RegisterSignalNotify() - Any errors show below"
echo
@ cnt = $MAXITER
while (0 < $cnt)
    # Note ydbgo34a.outxcur, ydbgo34a.outxtxt and ydbgo34a.diff are re-created on each iteration.
    `pwd`/ydbgo34a >& ydbgo34a.outxcur
    @ cnt = $cnt - 1
    @ runnum = $MAXITER - $cnt
    # Process each run separately so this M program can read which signal was used above and use to restrict
    # what KILLBYSIG messages we suppress (don't want to suppress cores we weren't expecting).
    $ydb_dist/yottadb -run ydbgo34 < ydbgo34a.outxcur >& ydbgo34a.outxtxt
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
echo "# Rename any core file and/or fatal error files to hide them from the framework as they aren't"
echo "# necessarily indicative of a problem"
set nonomatch; set cores=(core*); unset nonomatch
if ("core*" != "$cores") then      # Only do this if there are cores to rename
    foreach core ($cores)
	mv $core ydbgo34a_$core
    end
endif
# Uncomment the below once YDB#790 [TODO] is done
#set nonomatch; set yfezds=(YDB_FATAL_ERROR.ZSHOW_DMP_*); unset nonomatch
#if ("YDB_FATAL_ERROR.ZSHOW_DMP_*" != "$yfezds") then
#    foreach yfezd ($yfezds)     # Only do this if there are fatal error files to rename
#	mv $yfezd ydbgo34a_$yfezd
#    end
#endif

#
# And now setup ydbgo34b to test yottadb.UnRegisterSignalNotify()
#
echo
$echoline
echo "# Run ydbgo34b to test to test yottadb.UnRegisterSignalNotify(). This is done by sending a simple"
echo "# signal 3 times: (1) no handler set, (2) set a handler, (3) unset that handler."
cd ..
mkdir ydbgo34b
cd ydbgo34b
ln -s $gtm_tst/$tst/inref/ydbgo34b.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link ydbgo34b.go to current directory ($PWD)"
    exit 1
endif
echo "# Building ydbgo34b"
echo >> go_build.log
echo >> go_build.log
$gobuild >>& go_build.log
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build ydbgo34b.go. go_build.log output follows"
    cat go_build.log
    exit 1
endif
echo "Run ydbgo34b"
`pwd`/ydbgo34b
#
# Setup ydbgo34c to test when yottadb.RegisterSignalNotify() is passed an unsupported signal
#
echo
$echoline
echo "# Run ydbgo34c to test passing an unsupported signal to yottadb.RegisterSignalNotify()"
cd ..
mkdir ydbgo34c
cd ydbgo34c
ln -s $gtm_tst/$tst/inref/ydbgo34c.go .
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to soft link ydbgo34c.go to current directory ($PWD)"
    exit 1
endif
echo "# Building ydbgo34c"
echo >> go_build.log
echo >> go_build.log
$gobuild >>& go_build.log
if (0 != $status) then
    echo "TEST-E-FAILED : Unable to build ydbgo34c.go. go_build.log output follows"
    cat go_build.log
    exit 1
endif
echo "Run ydbgo34c"
`pwd`/ydbgo34c
#
# All done - Validate DB
#
echo
$echoline
echo "# Validate DB"
cd ../../..
unsetenv ydb_gbldir
$gtm_tst/com/dbcheck.csh
