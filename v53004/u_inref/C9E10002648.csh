#!/usr/local/bin/tcsh -f
#
# C9E10-002648 $O(^GBL(""),-1) gives incorrect result if ^GBL($C(255))) is defined
#

$gtm_tst/com/dbcreate.csh mumps -key=255 -rec=512

$GTM << GTM_EOF
	do ^c002648
GTM_EOF

$gtm_tst/com/dbcheck.csh

echo "End of C9E10002648 test..."
