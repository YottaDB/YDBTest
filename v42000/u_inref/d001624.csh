#! /usr/local/bin/tcsh -f
#!
#
unsetenv test_replic   
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << aaa
d ^d001624
aaa
$gtm_tst/com/dbcheck.csh
