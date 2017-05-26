#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run lvnstacking
$gtm_tst/com/dbcheck.csh -extract
