#!/usr/local/bin/tcsh -f

$gtm_tst/com/dbcreate.csh mumps

$gtm_exe/mumps -run gtm7553

$gtm_tst/com/dbcheck.csh
