#!/usr/local/bin/tcsh
#
# C9B10-001765 $Order() can give bad result if 2nd arg is an extrinsic that manipulates 1st arg
#
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << GTM_EOF
	do ^c001765
GTM_EOF
$gtm_tst/com/dbcheck.csh
