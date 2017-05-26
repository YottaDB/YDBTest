#!/usr/local/bin/tcsh
#
# C9B10-001744 $Order() can return wrong value if 2nd expr contains gvn
#
$gtm_tst/com/dbcreate.csh mumps 1
$DSE << DSE_EOF
	change -file -null=TRUE
DSE_EOF

$GTM << GTM_EOF
	do ^c001744
GTM_EOF
$gtm_tst/com/dbcheck.csh
