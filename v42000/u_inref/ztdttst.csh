#! /usr/local/bin/tcsh -f
# C9A06-001521 $T is not maintained as documented
unsetenv test_replic   
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << aaa
d ^ztdttst
aaa
$gtm_tst/com/dbcheck.csh
