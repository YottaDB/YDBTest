#!/usr/local/bin/tcsh -f
setenv gtm_trigger_etrap 'write $zstatus,! set $ecode=""'
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run trigbadchar
$gtm_tst/com/dbcheck.csh
