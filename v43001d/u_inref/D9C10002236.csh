#! /usr/local/bin/tcsh -f
#
source $gtm_tst/com/dbcreate.csh mumps
$GTM<<EOF
d ^d002236
h
EOF
#
$gtm_tst/com/dbcheck.csh -extract 
