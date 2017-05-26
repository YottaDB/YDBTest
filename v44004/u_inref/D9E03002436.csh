#! /usr/local/bin/tcsh -f
#D9E03-002436 MERGE and ZPRINT need to set restart point for interruptibility
#
echo "Beginning MERGE Interrupt testing"
#
$gtm_tst/com/dbcreate.csh mumps
#
$gtm_dist/mumps -run d002436 >&! d002436.out
$grep -vE '^$' d002436.out
$gtm_tst/com/dbcheck.csh
