#!/usr/local/bin/tcsh -f
#
# C9J03-003097 GT.M should close files (at the C-level) when there are errors during the M-open
#


$GTM << GTM_EOF
        do ^c003097
GTM_EOF


echo "End of C9J03003097 test..."
