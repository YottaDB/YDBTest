#!/usr/local/bin/tcsh -f
############################
#[D9I03-002677] Add -exact qualifier to lke clear
$gtm_tst/com/dbcreate.csh .
$GTM << xyz
w "do lkeexact",!  do ^lkeexact
xyz
#
$gtm_tst/com/dbcheck.csh  -extract
