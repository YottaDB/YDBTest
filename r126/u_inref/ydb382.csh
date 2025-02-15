#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that "lke clnup" clears unowned locks
#

echo '# Test that "lke clnup" clears unowned locks'
echo '# The LKE CLNUP command clears the lock space of locks abandoned by processes that exited abnormally'
echo '# In addition to the standard -region and -all flags, the command has two optional command line flags:'
echo '#	While the command by default runs once and terminates, the -periodic=n qualifier instructs LKE CLNUP to run in a loop, performing a cleanup every n seconds, a lighter weight operation than invoking the LKE command every n seconds from a shell script.'
echo '#	The -integ option instructs the command to also validate the data structures in the lock space for structural integrity.'

setenv gtm_test_spanreg 0 # set this to 0 to ensure that ^a is always in region AREG
$gtm_tst/com/dbcreate.csh mumps 2

echo '\n# locks prior to doing anything'
$gtm_dist/lke show
echo '# settings 3 locks and kill9ing their processes'
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^c write $zsigproc($job,9) hang 9999'
echo '# clnup no locks should be left'
$gtm_dist/lke clnup
$gtm_dist/lke show

echo '\n# settings 3 locks and kill9ing their processes'
($gtm_dist/mumps -run %XCMD 'set ^noclean=1 hang 9999' &; echo $! >&! mumpsA.pid) >&! /dev/null # leave a process open so shared memory wont get cleared
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^c write $zsigproc($job,9) hang 9999'
echo '# clnup -region=AREG locks should be left on ^b and ^c'
$gtm_dist/lke clnup -region=AREG
$gtm_dist/lke show
set ydbPID = `cat mumpsA.pid`
$gtm_dist/mupip stop $ydbPID # stop YDB M process in a long HANG command

echo '\n# settings 3 locks and kill9ing their processes'
($gtm_dist/mumps -run %XCMD 'set ^noclean=1 hang 9999' &; echo $! >&! mumpsB.pid) >&! /dev/null # leave a process open so shared memory wont get cleared
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^c write $zsigproc($job,9) hang 9999'
echo '# clnup -all no locks should be left'
$gtm_dist/lke clnup -all
$gtm_dist/lke show
set ydbPID = `cat mumpsB.pid`
$gtm_dist/mupip stop $ydbPID # stop YDB M process in a long HANG command

echo '\n# setting 2 orphaned locks: ^a, ^b; then locking: ^a, ^c in an open process'
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9) hang 9999'
# set a process that gets two locks (one owned, one orphaned) then hang for the lke clnup
# also sets a global variable so that we know when then locks are set to avoid race conditions on slower systems
($gtm_dist/mumps -run %XCMD 'lock ^c lock +^a set ^done(1)=1 hang 9999' &; echo $! >&! mumpsC.pid) >&! mumpsA.outx
$gtm_dist/mumps -run %XCMD 'for  quit:$get(^done(1))=1  hang 0.1'
echo '# cleanup there should be a lock on ^c, and ^a'
$gtm_dist/lke clnup
$gtm_dist/lke show
set ydbPID = `cat mumpsC.pid`
$gtm_dist/mupip stop $ydbPID # stop YDB M process in a long HANG command

echo '\n# testing -periodic switch'
($gtm_dist/lke clnup -periodic=5 &; echo $! >&! lkeA.pid) >&! lkeA.outx
($gtm_dist/mumps -run %XCMD 'set ^done(2)=1 hang 9999' &; echo $! >&! mumpsD.pid) >&! /dev/null # leave a process open so shared memory wont get cleared
$gtm_dist/mumps -run %XCMD 'for  lock:$get(^done(2))=1 ^waitForThis write:$get(^done(2))=1 $zsigproc($job,9) hang 0.1'
# Busy wait here for a clnup trigger this will sync the two processes
# Output should appear since an orphaned lock was set above
set foundStr = 1
while (0 != $foundStr)
	$gtm_dist/lke show >&! lkeshow.outx
	grep "^%YDB-I-NOLOCKMATCH.*DEFAULT" lkeshow.outx >& /dev/null
	set foundStr = $status
	sleep 0.5
end
echo '# Note down lke -periodic output in lkeA1.outx after 1st round of orphaned lock cleanup'
cp lkeA.outx lkeA1.outx
echo '# Start processes which will hold locks and get kill -9ed to create 2nd round of orphaned locks'
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^c write $zsigproc($job,9) hang 9999'
echo '# waiting for periodic to trigger'
sleep 6
echo '# clnup no locks should be left'
$gtm_dist/lke show
echo '# Diff lke -periodic output after 2nd round of orphaned lock cleanup with lkeA1.outx'
echo '# We expect to 2 OR 3 MLKCLEANED lines (1 for AREG AND 1 or 2 for DEFAULT) with a total'
echo '# of 3 lock slots across those lines corresponding to the 3 orphaned locks of ^a,^b,^c'
# Note that lkeA1.outx sometimes contains 2 lines and sometimes 3 lines of output and so the
# diff output will have non-deterministic first line of output ("2a3,4" vs "4a5,6"). It is not
# clear why this happens and is not considered important for the purposes of this test where we
# care about the 2 MLKCLEANED lines and so we filter that out by doing a "tail -n +2" below.
diff lkeA1.outx lkeA.outx | tail -n +2 | $tst_awk '									\
		BEGIN   {sum = 0;}											\
		        {sum += $7;}											\
		END     {printf "Number of total MLKCLEANED lock slots : Expected = [3] : Actual = [%d]\n", sum;}'
set lkePID = `cat lkeA.pid`
$gtm_dist/mupip stop $lkePID
set ydbPID = `cat mumpsD.pid`
$gtm_dist/mupip stop $ydbPID # stop YDB M process in a long HANG command
# wait for process to die and remove db shm before next test starts
$gtm_tst/com/wait_for_proc_to_die.csh $lkePID
$gtm_tst/com/wait_for_proc_to_die.csh $ydbPID

echo '\n# testing -integ switch'
echo '# settings 3 locks and kill9ing their processes'
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^c write $zsigproc($job,9) hang 9999'
echo '# clnup -integ no locks should be left and lock space should be clean'
$gtm_dist/lke clnup -integ
$gtm_dist/lke show

echo '\n# setting 3 orphaned locks set by 3 processes, while one ydb process is left open'
($gtm_dist/mumps -run %XCMD 'set ^done(3)=1 hang 9999' &; echo $! >&! mumpsE.pid) >&! /dev/null
$gtm_dist/mumps -run %XCMD 'for  quit:$get(^done(3))=1  hang 0.1'
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9) hang 9999'
$gtm_dist/mumps -run %XCMD 'lock ^c write $zsigproc($job,9) hang 9999'
echo '# clnup no locks should be left'
$gtm_dist/lke clnup
$gtm_dist/lke show
set ydbPID = `cat mumpsE.pid`
$gtm_dist/mupip stop $ydbPID # stop YDB M process in a long HANG command
$gtm_tst/com/wait_for_proc_to_die.csh $ydbPID

$gtm_tst/com/dbcheck.csh
