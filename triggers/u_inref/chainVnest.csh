#!/usr/local/bin/tcsh
unsetenv gtm_gvdupsetnoop
$gtm_tst/com/dbcreate.csh mumps 1
# test/triggers/inref/chainVnest.m
$gtm_exe/mumps -run chainVnest
$gtm_tst/com/dbcheck.csh
