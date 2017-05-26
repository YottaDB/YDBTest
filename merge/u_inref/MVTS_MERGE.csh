#!/usr/local/bin/tcsh -f
#
setenv test_reorg "NON_REORG"
source $gtm_tst/com/dbcreate.csh mumps 4 255 1000
$GTM << xyz
d ^V4MERGE
h
xyz
$gtm_tst/com/dbcheck.csh -extr
