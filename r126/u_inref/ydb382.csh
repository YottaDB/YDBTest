#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that "lke clnup" will clears unowned locks
#

echo '# Test that "lke clnup" will clears unowned locks'
echo '# The LKE CLNUP command clears the lock space of locks abandoned by processes that exited abnormally'
echo '# In addition to the standard -region and -all flags, the command has two optional command line flags:'
echo '#	While the command by default runs once and terminates, the -periodic=n qualifier instructs LKE CLNUP to run in a loop, performing a cleanup every n seconds, a lighter weight operation than invoking the LKE command every n seconds from a shell script.'
echo '#	The -integ option instructs the command to also validate the data structures in the lock space for structural integrity.'

setenv gtm_test_spanreg 0 # set this to 0 to ensure that ^a is always in region AREG
$gtm_tst/com/dbcreate.csh mumps 2

echo '\n# locks prior to doing anything'
$gtm_dist/lke show
echo '# settings 3 locks and kill9ing their processes'
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^c write $zsigproc($job,9)'
echo '# clnup no locks should be left'
$gtm_dist/lke clnup
$gtm_dist/lke show

echo '\n# settings 3 locks and kill9ing their processes'
($gtm_dist/mumps -run %XCMD 'set ^noclean=1 hang 9999' &; echo $! >&! lke.pid) >&! /dev/null # leave a process open so shared memory wont get cleared
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^c write $zsigproc($job,9)'
echo '# clnup -region=AREG locks should be left on ^b and ^c'
$gtm_dist/lke clnup -region=AREG
$gtm_dist/lke show
set ydbPID = `cat lke.pid`
$gtm_dist/mupip stop $ydbPID # stop hanged ydb process and cleanup

echo '\n# settings 3 locks and kill9ing their processes'
($gtm_dist/mumps -run %XCMD 'set ^noclean=1 hang 9999' &; echo $! >&! lke.pid) >&! /dev/null # leave a process open so shared memory wont get cleared
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^c write $zsigproc($job,9)'
echo '# clnup -all no locks should be left'
$gtm_dist/lke clnup -all
$gtm_dist/lke show
set ydbPID = `cat lke.pid`
$gtm_dist/mupip stop $ydbPID # stop hanged ydb process and cleanup

echo '\n# setting 2 orphaned locks: ^a, ^b; then locking: ^a, ^c in an open process'
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9)'
# set a process that gets two locks (one owned, one orphaned) then hang for the lke clnup
# also sets a global variable so that we know when then locks are set to avoid race conditions on slower systems
($gtm_dist/mumps -run %XCMD 'lock ^c lock +^a set ^done(1)=1 hang 9999' &; echo $! >&! lke.pid) >&! lke1.outx
$gtm_dist/mumps -run %XCMD 'for  quit:$get(^done(1))=1  hang 0.001'
echo '# cleanup there should be a lock on ^c, and ^a'
$gtm_dist/lke clnup
$gtm_dist/lke show
set ydbPID = `cat lke.pid`
$gtm_dist/mupip stop $ydbPID # stop hanged ydb process and cleanup

echo '\n# testing -periodic switch'
($gtm_dist/lke clnup -periodic=5 &; echo $! >&! lke.pid) >&! lke2.outx
sleep 1 # sleep here because -periodic tirggers once immediately
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^c write $zsigproc($job,9)'
echo '# list of locks before lke clnup -periodic triggers'
$gtm_dist/lke show
echo '# waiting for periodic to trigger'
sleep 6
echo '# clnup no locks should be left'
$gtm_dist/lke show
set lkePID = `cat lke.pid`
$gtm_dist/mupip stop $lkePID

echo '\n# testing -integ switch'
echo '# settings 3 locks and kill9ing their processes'
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^c write $zsigproc($job,9)'
echo '# clnup -integ no locks should be left and lock space should be clean'
$gtm_dist/lke clnup -integ
$gtm_dist/lke show

echo '\n# setting 3 orphaned locks set by 3 processes, while one ydb process is left open'
($gtm_dist/mumps -run %XCMD 'set ^done(2)=1 hang 9999' &; echo $! >&! lke.pid) >&! lke3.outx
$gtm_dist/mumps -run %XCMD 'for  quit:$get(^done(2))=1  hang 0.001'
$gtm_dist/mumps -run %XCMD 'lock ^a write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^b write $zsigproc($job,9)'
$gtm_dist/mumps -run %XCMD 'lock ^c write $zsigproc($job,9)'
echo '# clnup no locks should be left'
$gtm_dist/lke clnup
$gtm_dist/lke show
set ydbPID = `cat lke.pid`
$gtm_dist/mupip stop $ydbPID # stop hanged ydb process and cleanup

$gtm_tst/com/dbcheck.csh
