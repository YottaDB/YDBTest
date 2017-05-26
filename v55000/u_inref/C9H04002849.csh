#!/usr/local/bin/tcsh -f
#
# C9H04-002849 - Verify that LOCK command waits the correct time
#
$gtm_tst/com/dbcreate.csh .
$gtm_dist/mumps -run ^c002849
$gtm_tst/com/dbcheck.csh
