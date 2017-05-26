#!/usr/local/bin/tcsh -f
#
# C9905-001119 GT.M should handle first-time global reference (with nonzero out-of-date clue) when in final TP retry
#

$gtm_tst/com/dbcreate.csh mumps -blk=512 -glo=64

$GTM << GTM_EOF
        do ^c001119
GTM_EOF

$gtm_tst/com/dbcheck.csh

echo "End of C9905001119 test..."
