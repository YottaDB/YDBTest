#!/usr/local/bin/tcsh -f

# D9D11002390 ZSTEP OVER produces abnormal termination (SIG 4)
# Although this was found to be a HP-PA issue only, we run this test for all
# platforms to serve as a regression test
#
$GTM << GTM_EOF
zbreak ^d002390
do ^d002390
zstep over
halt
GTM_EOF

exit 0
