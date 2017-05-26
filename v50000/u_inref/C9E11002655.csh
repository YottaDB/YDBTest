#!/usr/local/bin/tcsh
#
# C9E11-002655 Large number of global variables created within TP transaction corrupts database
#

$gtm_tst/com/dbcreate.csh mumps 1 255 480 512 100 16384

$GTM << GTM_EOF
	do set^c002655
GTM_EOF

$gtm_tst/com/dbcheck.csh

$GTM << GTM_EOF
	do verify^c002655
GTM_EOF

