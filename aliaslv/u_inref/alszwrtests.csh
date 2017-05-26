#!/usr/local/bin/tcsh -f
#
# Testing ZWrite in an aliasing environment
#
$gtm_tst/com/dbcreate.csh .
$gtm_dist/mumps -run ^zwrtests
$gtm_tst/com/dbcheck.csh
