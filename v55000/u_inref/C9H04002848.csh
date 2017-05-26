#!/usr/local/bin/tcsh -f
#
# C9H04-002848 - Verify that HANG command waits the correct time
#
$gtm_tst/com/dbcreate.csh .
$gtm_dist/mumps -run ^c002848
$gtm_tst/com/dbcheck.csh
