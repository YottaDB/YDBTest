#!/usr/local/bin/tcsh -f

$gtm_tst/com/dbcreate.csh . 4

$GTM << GTM_EOF
	do ^d002164a
GTM_EOF
$gtm_tst/com/dbcheck.csh
