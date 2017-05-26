#!/bin/ksh
# setup GT.M environment - normally would be sourced
cd /testarea/gtmtest/V990
gtm_dist=/usr/library/V990/dbg
gtmroutines="/testarea/gtmtest/V990 $gtm_dist"
export gtm_dist
export gtmroutines
$gtm_dist/mumps -r 'INETD^d002119server'
exit
