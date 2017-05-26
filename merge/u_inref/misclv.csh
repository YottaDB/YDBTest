#!/usr/local/bin/tcsh -f
setenv test_reorg "NON_REORG"  
$gtm_exe/mumps -dir << aaa
d ^mergelv
halt
aaa
