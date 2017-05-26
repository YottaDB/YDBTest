#!/usr/local/bin/tcsh -f
#
# D9D08-002354 $GET(glvn, lcl2) does not work right when lcl2 is undefined
#

$gtm_tst/com/dbcreate.csh mumps

$GTM << GTM_EOF
        do ^d002354
GTM_EOF

$gtm_tst/com/dbcheck.csh
