#!/usr/local/bin/tcsh

setenv inrefdir "$gtm_tst/$tst/inref"
setenv EDITOR "$gtm_tst/$tst/u_inref/zed.csh"

$GTM << EOF
w "do zed^zed",! d zed^zed
EOF
