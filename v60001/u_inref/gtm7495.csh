#!/usr/local/bin/tcsh -f

echo "Begin gtm7495"
$gtm_tst/com/dbcreate.csh mumps

$gtm_exe/mumps -run gtm7495

$gtm_tst/com/dbcheck.csh
echo "End gtm7495"
