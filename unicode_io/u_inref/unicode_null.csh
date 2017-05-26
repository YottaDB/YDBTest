#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << aaa
write "do ^unicodenull",!
do ^unicodenull
h
aaa
$gtm_tst/com/dbcheck.csh 
