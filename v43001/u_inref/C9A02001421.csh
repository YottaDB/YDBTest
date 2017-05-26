#! /usr/local/bin/tcsh -f
#
echo "Beginning Job Interrupt testing"
#
$gtm_tst/com/dbcreate.csh mumps
#
$gtm_dist/mumps -run tzintr >&! tzintr.out
$grep -vE '^$' tzintr.out
$gtm_tst/com/dbcheck.csh
