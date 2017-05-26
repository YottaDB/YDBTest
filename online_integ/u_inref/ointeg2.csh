#!/usr/local/bin/tcsh -f
# This subtest verifies that mupip online integ reports an error if it is run on a V4 database

# Force it to be a V4 database
setenv gtm_test_mupip_set_version "V4"

$gtm_tst/com/dbcreate.csh mumps 1 

$GTM << EOF
set ^a=3
set ^b=5
h
EOF

$echoline
echo "# Run online integ to verify it does not support V4 databases"
$echoline
set mupip_log1 = "mupip_log1.log"
$MUPIP integ $FASTINTEG -online -preserve -r DEFAULT >&! $mupip_log1

$echoline
echo "# Verify SSV4NOALLOW error is present."
$echoline
$gtm_tst/com/check_error_exist.csh $mupip_log1 SSV4NOALLOW MUNOTALLINTEG

$gtm_tst/com/dbcheck.csh
