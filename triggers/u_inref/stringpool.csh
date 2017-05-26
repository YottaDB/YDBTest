#!/usr/local/bin/tcsh -f
setenv test_specific_trig_file $gtm_tst/$tst/inref/stringpool.trg
setenv gtm_trigger_etrap 'Write "BASE HALT",! ZShow "*" ZHalt 1'

$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run stringpool

$gtm_tst/com/dbcheck.csh -extract
