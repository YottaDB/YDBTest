#!/usr/local/bin/tcsh -f
#
# Test nested error handling in multiple ways
#
$gtm_tst/com/dbcreate.csh .
#
# Test nested error handling using GOTO invocation of error handler and etr1 (error trap does TRESTART)
#
$gtm_dist/mumps -run flavor1^gtm7355
echo
echo
echo
#
# Test nested error handling using DO invocation of error handler and etr1 (error trap does TRESTART)
#
$gtm_dist/mumps -run flavor2^gtm7355
echo
echo
echo
#
# Test nested error handling with entire error handler contained in $ETRAP
#
$gtm_dist/mumps -run flavor3^gtm7355
echo
echo
echo
#
# Test nested error handling using GOTO invocation of error handler and etr2 (error trap drives ZINTERRUPT which does TRESTART)
#
$gtm_dist/mumps -run flavor4^gtm7355
echo
echo
echo
#
# Test nested error handling using DO invocation of error handler and etr1 (error trap drive ZINTERRUPT which does TRESTART)
#
$gtm_dist/mumps -run flavor5^gtm7355
echo
echo
echo
#
$gtm_tst/com/dbcheck.csh
