#!/usr/local/bin/tcsh -f
unsetenv gtm_gvdupsetnoop
$gtm_tst/com/dbcreate.csh mumps 1
# test/triggers/inref/ztriggvn.m
$gtm_exe/mumps -run ztriggvn
$gtm_tst/com/dbcheck.csh -extract
