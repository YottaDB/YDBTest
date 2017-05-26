#!/usr/local/bin/tcsh -f
#
# C9H02-002826 Various numeric anomalies
#
$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run C9H02002826
$gtm_tst/com/dbcheck.csh
