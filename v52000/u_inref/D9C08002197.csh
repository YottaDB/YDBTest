#!/usr/local/bin/tcsh
#
# D9C08-002197 Multiple local array based extended references on left of SET causes ACCVIO
#
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << GTM_EOF
	do test11^d002197
GTM_EOF
$GTM << GTM_EOF
	do test12^d002197
GTM_EOF
$GTM << GTM_EOF
	do test21^d002197
GTM_EOF
$GTM << GTM_EOF
	do test22^d002197
GTM_EOF
$gtm_tst/com/dbcheck.csh
