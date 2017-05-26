#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run all^symmetry  | sed 's/: [0-9][0-9]*$/: X/'
$gtm_tst/com/dbcheck.csh -extract
