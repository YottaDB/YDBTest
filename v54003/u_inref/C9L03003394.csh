#!/usr/local/bin/tcsh -f
#
# C9L03-003394 check $REFERENCE after MERGE
#
$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run C9L03003394
$gtm_tst/com/dbcheck.csh
