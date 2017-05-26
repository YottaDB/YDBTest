#!/usr/local/bin/tcsh
# disable implicit mprof testing to avoid interference with explicit mprof testing
unsetenv gtm_trace_gbl_name
source $gtm_tst/com/dbcreate.csh mumps 1
# test/triggers/inref/trigmprof.m
$gtm_exe/mumps -run trigmprof
$gtm_tst/com/dbcheck.csh
