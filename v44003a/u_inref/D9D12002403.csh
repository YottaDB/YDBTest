#!/usr/local/bin/tcsh
#
# D9D12002403 [Malli] Setting ZBREAK on line accessing more than 8 locals fails
#
$GTM<<EOF
w "Testing D9D12-002403...",!
d main^zbtst
h
EOF
