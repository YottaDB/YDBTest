#!/usr/local/bin/tcsh
#
# C9I02-002963 Test that SET $ZGBLDIR followed by TSTART does NOT fail with SIG-11
#
$gtm_tst/com/dbcreate.csh mumps

$GTM << GTM_EOF
	do ^c002963
GTM_EOF

$gtm_tst/com/dbcheck.csh
