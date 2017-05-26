#!/usr/local/bin/tcsh -f
 
$gtm_tst/com/dbcreate.csh mumps
 
$GTM << GTM_EOF
d ^c002170
GTM_EOF
$gtm_tst/com/dbcheck.csh
