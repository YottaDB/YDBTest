#!/usr/local/bin/tcsh -f
#
# Make sure the basic functionality of aliasing works
#
$gtm_tst/com/dbcreate.csh .

$gtm_dist/mumps -run ^basicals1
$gtm_dist/mumps -run ^basicals2
# Nothing is left over in global database so no point checking it
$gtm_dist/mumps -run ^basicals3
$gtm_tst/com/dbcheck.csh
