#!/usr/local/bin/tcsh -f

$gtm_tst/$tst/u_inref/basic_base.csh >>&! basic_base.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk basic_base.log
