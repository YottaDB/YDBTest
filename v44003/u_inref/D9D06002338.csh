#!/usr/local/bin/tcsh -f
#
$gtm_tst/com/dbcreate.csh mumps 1
\cp $gtm_tst/com/sstep.m .
\cp mumps.gld other.gld
$GTM<<EOF
d ^d002338
h
EOF
$gtm_tst/com/dbcheck.csh

