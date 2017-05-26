#!/usr/local/bin/tcsh -f

# test VIEW "JNLFLUSH" for a previously unopened region

$gtm_tst/com/dbcreate.csh mumps 1 255 1000

$GTM << GTM_EOF
d ^d002203
GTM_EOF
$gtm_tst/com/dbcheck.csh
