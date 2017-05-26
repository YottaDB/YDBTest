#!/usr/local/bin/tcsh -f
#
# D9K06-002779 TP restarts due to M-locks should not go on indefinitely
#
$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run test1^d002779
$gtm_dist/mumps -run test2^d002779
$gtm_tst/com/dbcheck.csh
