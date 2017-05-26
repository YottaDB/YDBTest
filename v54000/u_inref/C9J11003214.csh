#!/usr/local/bin/tcsh -f
#
# C9J11-003214 Not validating clue in final retry causes TPFAIL GGGG errors in V53004
#
$gtm_tst/com/dbcreate.csh mumps -glo=64

$GTM << GTM_EOF
        do ^c003214
GTM_EOF

$gtm_tst/com/dbcheck.csh
