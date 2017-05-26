#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run test^trigzsource
$gtm_tst/com/dbcheck.csh -extract
