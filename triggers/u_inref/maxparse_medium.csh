#!/usr/local/bin/tcsh -f
source $gtm_tst/com/dbcreate.csh mumps 1 255 32000 32256 1024

source $gtm_tst/$tst/u_inref/maxparse_base.csh

$gtm_tst/com/dbcheck.csh -extract
