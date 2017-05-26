#!/usr/local/bin/tcsh -f

# test that LOCK accepts extended reference syntax for nrefs in the form of locals

$gtm_tst/com/dbcreate.csh mumps 1 255 1000

$GTM << GTM_EOF
d ^c002209
GTM_EOF
$gtm_tst/com/dbcheck.csh
