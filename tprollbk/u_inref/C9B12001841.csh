#!/usr/local/bin/tcsh -f
#
# C9B12-001841 check $REFERENCE after a partial rollback
#
$gtm_tst/com/dbcreate.csh mumps 2
$gtm_exe/mumps -run C9B12001841
$gtm_tst/com/dbcheck.csh -extract
