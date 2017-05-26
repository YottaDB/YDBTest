#!/usr/local/bin/tcsh -f
#
# D9E04002439 C-stack leaks if a local variable is passed by reference through indirection

# disable implicit mprof testing to avoid interference with explicit mprof testing
unsetenv gtm_trace_gbl_name

$gtm_tst/com/dbcreate.csh mumps 1

$GTM << GTM_EOF
do d002439^d002439("indlvadr")
halt
GTM_EOF

$GTM << GTM_EOF
do d002439^d002439("indlvnamadr")
halt
GTM_EOF

$gtm_tst/com/dbcheck.csh
