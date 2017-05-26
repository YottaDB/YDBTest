#!/usr/local/bin/tcsh
#
# C9D12-002478 [Malli] marvin dbg cores with v44003 (find_line_addr has SEGV)
#
$GTM<<EOF
w "Testing C9D12-002478...",!
w "d ind^c002478",! d ind^c002478
w "d rtn^c002478",! d rtn^c002478
h
EOF
