#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 5 255 4096 8192
$gtm_exe/mumps -run longnames
$gtm_tst/com/dbcheck.csh -extract
