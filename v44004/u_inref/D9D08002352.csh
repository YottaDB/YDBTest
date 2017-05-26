#!/usr/local/bin/tcsh -f

# D9D08-002352 $Q() fails on nodes with "" in last subscript
#
$GTM << GTM_EOF
do ^d002352
halt
GTM_EOF
