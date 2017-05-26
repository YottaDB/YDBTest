#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 4096 2000 4096 2000
$gtm_exe/mumps -run ztrigio
$gtm_tst/com/dbcheck.csh -extract
