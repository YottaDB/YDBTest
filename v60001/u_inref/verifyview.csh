#!/usr/local/bin/tcsh -f

$gtm_tst/com/dbcreate.csh mumps 1
setenv gtm_tprestart_log_delta 3
$gtm_exe/mumps -r %XCMD "do envview^verifyview"
unsetenv gtm_tprestart_log_delta
$gtm_exe/mumps -r %XCMD "do mumpsview^verifyview"
$gtm_tst/com/dbcheck.csh
