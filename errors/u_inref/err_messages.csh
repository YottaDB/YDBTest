#!/usr/local/bin/tcsh -f

echo "############################################################################"
$gtm_tst/com/dbcreate.csh . 3
echo "############################################################################"
echo "ANSI ERRORS"
echo ""
$gtm_exe/mumps -run erransi

echo "############################################################################"
echo ""
$gtm_exe/mumps -run errdemo
echo "############################################################################"
echo "GTM ERRORS"
echo ""
$gtm_exe/mumps -run errgtm
echo "############################################################################"
echo "GTM ETRAP/ZTRAP interaction"
echo ""
$gtm_exe/mumps -run tstetzt

$gtm_tst/com/dbcheck.csh
