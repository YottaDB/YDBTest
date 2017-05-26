#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run zbspfortrig
$gtm_tst/com/dbcheck.csh -extract
