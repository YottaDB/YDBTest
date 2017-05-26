#!/usr/local/bin/tcsh -f
#
#
$gtm_tst/com/dbcreate.csh mumps 1
\cp $gtm_tst/$tst/inref/gi.go .
$GTM<<EOF
w !,"d ^%GI",! d ^%GI
gi.go
use \$p
w !,"Verifying globals:"
w !,"d ^%GD",! d ^%GD
*

h
EOF
$gtm_tst/com/dbcheck.csh

