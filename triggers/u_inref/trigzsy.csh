#!/usr/local/bin/tcsh -f
setenv gtm_trigger_etrap 'w $c(9),"$zlevel=",$zlevel," : $ztlevel=",$ztle," : $ZSTATUS=",$zstatus,! s $ecode=""'
$gtm_tst/com/dbcreate.csh mumps 1
unsetenv gtm_trigger_etrap
unsetenv gtm_gvdupsetnoop
$gtm_exe/mumps -run trigzsy
$gtm_tst/com/dbcheck.csh -extract
