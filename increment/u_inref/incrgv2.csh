#! /usr/local/bin/tcsh -f
echo "incrgv2 subtest -  increment within TP of global variables that are NOISOLATED"
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << \aa
do ^incrgv2
\aa
$gtm_tst/com/dbcheck.csh 
echo "End  of subtest"
