#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$gtm_tst/com/dbcreate.csh mumps 1 255 700 
unsetenv gtm_patnumeric 
$GTM << FIN 
d ^c001953
h
FIN
$gtm_tst/com/dbcheck.csh 
