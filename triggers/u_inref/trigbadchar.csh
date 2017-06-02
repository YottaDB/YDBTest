#!/usr/local/bin/tcsh -f
setenv gtm_trigger_etrap 'write $zstatus,! set $ecode=""'
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run trigbadchar
source $gtm_tst/com/ydb_trig_upgrade_check.csh
$gtm_tst/com/dbcheck.csh
