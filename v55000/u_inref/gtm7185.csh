#!/usr/local/bin/tcsh -f
#
# GTM-7185 FOR loop with subscripted increment and termination
#
echo Starting gtm6957
$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run gtm7185
$gtm_tst/com/dbcheck.csh
