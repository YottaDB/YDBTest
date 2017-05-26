#!/usr/local/bin/tcsh -f
# gtm7525		[base]		Verify locks resume blocking wait after receiving an INTRPT

$gtm_tst/com/dbcreate.csh mumps

echo "# Launching gtm7525.m"
$gtm_exe/mumps -run gtm7525

$gtm_tst/com/dbcheck.csh
