#!/usr/local/bin/tcsh -f
echo "Test Case: 07 tp_ztp_mixup"
$gtm_tst/com/dbcreate.csh mumps 1
$GTM <<aa
w "d t1^ztptp",! d t1^ztptp
aa
$GTM <<aa
w "d t2^ztptp",! d t2^ztptp
aa
$GTM <<aa
w "d t3^ztptp",! d t3^ztptp
aa
$gtm_tst/com/dbcheck.csh
