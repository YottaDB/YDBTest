#!/usr/local/bin/tcsh -f
#
$gtm_tst/com/dbcreate.csh mumps
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM <<EOF
Do ^chkbroksock
EOF
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/portno_release.csh
