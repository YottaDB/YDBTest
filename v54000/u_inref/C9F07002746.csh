#!/usr/local/bin/tcsh -f
#
# C9F07-002746 $INCR on an undefined global does not force alphanumeric string to numeric
#
$gtm_tst/com/dbcreate.csh mumps

$GTM << GTM_EOF
        do ^c002746
GTM_EOF

$gtm_tst/com/dbcheck.csh
