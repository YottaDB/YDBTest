#!/usr/local/bin/tcsh -f

# test that zwr of globals and locals and zsearch with fixed length patterns works fine

$gtm_tst/com/dbcreate.csh mumps 1 255 1000

$GTM << GTM_EOF
d ^c002186
GTM_EOF
$gtm_tst/com/dbcheck.csh
