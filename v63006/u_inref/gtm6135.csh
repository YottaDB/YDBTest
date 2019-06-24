#!/usr/local/bin/tcsh
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
#
#

setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"
echo '# Test of all the functions of the ISV $ztimeout'
echo '# The $ZTIMeout=([timeout][:labelref]) Intrinsic Special Variable (ISV) controls a single process wide timer'
echo '# The optional timeout in seconds specifies with millisecond accuracy how long from the current time the timer interrupts the process'
echo '# If the specified timeout is negative, GT.M cancels the timer'
echo '# If the timeout is zero, GT.M treats it as it would a DO of the vector'
echo '# The optional labelref specifies a code vector defining a fragment of M code to which GT.M transfers control as if with a DO when the timeout expires'
echo '# If the timeout is missing, the assignment must start with a colon and only changes the vector, and in this case, if the vector is the empty string, GT.M removes any current vector'
echo '# Note that GT.M only recognizes interrupts, such as those from $ZTIMEOUT at points where it can properly resume operation, for example, at the beginning of a line, when waiting on a command with a timeout, or when starting a FOR iteration'
echo '# When a ztimeout occurs, if the last assignment specified no vector, GT.M uses the current $ETRAP or $ZTRAP with a status warning of ZTIMEOUT'
echo '# GT.M rejects an attempted KILL of $ZTIMeout with an error of %GTM-E-VAREXPECTED, and an attempted NEW of $ZTIMeout with an error of %GTM-E-SVNONEW.'

echo; echo '# This test does not test the millisecond accuracy (just that it does not trigger before expected)'
echo '# Does not test interuption only at start of lines/forloops, or in hangs'

$gtm_tst/com/dbcreate.csh mumps

# this file contains the all of the tests for gtm6135
# but the seperate process test happens below
echo '# There will be compile issues here with new $ztimeout and kill $ztimeout; this is part of the test'
$gtm_dist/mumps -run gtm6135

# error tests
$gtm_dist/mumps -run newztimeout^gtm6135
$gtm_dist/mumps -run killztimeout^gtm6135


# test for $ztimeout in different processes
echo 'Check that $ztimeout is different for each process'
echo 'Starting timeouts in two different processes one does set ^a(1)'
echo 'The other does set ^a(2) and both globals should be set'
($gtm_dist/mumps -run backgroundA^gtm6135 &; echo $! >&! bgA.pid) >&! bgA.out
($gtm_dist/mumps -run backgroundB^gtm6135 &; echo $! >&! bgB.pid) >&! bgB.out
$gtm_dist/mumps -run %XCMD 'set ^start(1)=1 for  quit:$get(^done(1))=1&$get(^done(2))=1  hang 0.01'
$gtm_dist/mumps -run %XCMD 'write:^a(1)=1&^a(2)=1 "PASS ^a(1) and ^a(2) are correctly 1",!'
set pidA = `cat bgA.pid`
set pidB = `cat bgB.pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pidA $pidB

$gtm_tst/com/dbcheck.csh
