#!/usr/local/bin/tcsh -f
#
# D9I03-002674 Name indirection may fail with NOUNDEF
#

$gtm_tst/com/dbcreate.csh mumps 1

$GTM << EOF
do test^d002674(1)
h
EOF

$gtm_tst/com/dbcheck.csh
