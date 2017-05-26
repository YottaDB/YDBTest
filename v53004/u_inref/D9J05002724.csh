#!/usr/local/bin/tcsh -f
#
# D9J05-002724 Test that left side of the set is evaluated BEFORE the right side
#

$GTM << GTM_EOF
        do ^d002724
GTM_EOF

