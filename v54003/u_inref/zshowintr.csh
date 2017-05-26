#!/usr/local/bin/tcsh -f
#
# C9J06-003137 (zshowintr) - Verify that interrupted ZSHOW command resumes correctly
#
$gtm_tst/com/dbcreate.csh .
$gtm_dist/mumps -run ^zshowintr
$gtm_tst/com/dbcheck.csh
