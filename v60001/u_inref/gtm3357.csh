#!/usr/local/bin/tcsh -f

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log

# Run test
$gtm_exe/mumps -run gtm3357

$gtm_tst/com/dbcheck.csh >& dbcheck.log
