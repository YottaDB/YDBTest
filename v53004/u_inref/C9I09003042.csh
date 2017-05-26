#!/usr/local/bin/tcsh -f
#
# C9I09003042 [Narayanan] Test repositioning logic happens only ONCE in gds_tp_hist_moved (see TR folder for details)
#
$gtm_tst/com/dbcreate.csh mumps 1

$GTM << GTM_EOF
	do ^c003042
GTM_EOF

$gtm_tst/com/dbcheck.csh
