#!/usr/local/bin/tcsh -f
setenv test_reorg "NON_REORG"
setenv gtmgbldir mrgclnup.gld
$gtm_tst/com/dbcreate.csh mrgclnup 1
$gtm_exe/mumps -dir << \GTM_EOF
d ^mrgclnup
h
\GTM_EOF
$gtm_tst/com/dbcheck.csh -extr
