#! /usr/local/bin/tcsh -f
#
$gtm_tst/com/dbcreate.csh .
$GTM << gtm_eof
write "Testing Intrinsic special variables",!
do ^isv
gtm_eof
#
$gtm_tst/com/dbcheck.csh
