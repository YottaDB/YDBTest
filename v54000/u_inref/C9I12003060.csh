#!/usr/local/bin/tcsh -f
#
# Test that LKE SHOW -OUTPUT issues appropriate error message if unable to create output file (e.g. permissions)
#
$gtm_tst/com/dbcreate.csh mumps

echo "LKE SHOW -OUTPUT should succeed on a non-existent file"
$LKE show -all -output="file.out"

echo "Change permissions of created file to read-only"
chmod -w file.out

echo "LKE SHOW -OUTPUT should FAIL on this read-only file"
$LKE show -all -output="file.out"

$gtm_tst/com/dbcheck.csh
