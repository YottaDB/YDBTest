#!/bin/bash
# setup GT.M environment - normally would be sourced
cd /testarea/gtmtest/V990
export gtm_dist=/usr/library/V990/dbg
export gtmroutines="/testarea/gtmtest/V990 $gtm_dist"
$gtm_dist/mumps -r "INETD^d002119server"
exit
