#!/usr/local/bin/tcsh -f
if ($gtm_test_crash == 1)	echo "This is a crash test"
if ("$1" != "") setenv gtm_test_jobcnt "$1"
$GTM << \xyz
set jobcnt=$$^jobcnt
w "do ^tpntp(jobcnt)",!  do ^tpntp(jobcnt)
h
\xyz
