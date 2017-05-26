#!/usr/local/bin/tcsh -f
# $1 = Number of process 	! Optional Parameter
#
# Always output should be redirectoed a file by caller.
# Because otherwise verbose output from job.m causes reference file problem
# By default usage of job.m from the M programs below cause verbose output
#
#
# If non-TP is chosen for crash tests to do application level verification some TP transactions are used in imptp.m.
# But GT.CM does not support TP for now, we will not use any TP transactions for it at all.
# We assume when GT.CM is chosen it will not be a crash test.
#
\pwd
if ($gtm_test_crash == 1)	echo "This is a crash test"
if ("GT.CM" == $test_gtm_gtcm) setenv gtm_test_is_gtcm 1
if ("$1" != "") setenv gtm_test_jobcnt "$1"
$GTM << \xyz
	w $zv,!
	set jobcnt=$$^jobcnt
	w "do ^v4imptp(jobcnt)",!  do ^v4imptp(jobcnt)
	h
\xyz
exit
