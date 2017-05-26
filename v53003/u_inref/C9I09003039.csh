#!/usr/local/bin/tcsh -f

$gtm_tst/com/dbcreate.csh mumps
$GTM << GTM_EOF
	do ^c003039
GTM_EOF
$gtm_tst/com/dbcheck.csh
echo "End of C9I09003039 test..."
