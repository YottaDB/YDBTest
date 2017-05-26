#!/usr/local/bin/tcsh -f

$gtm_tst/$tst/u_inref/extract_upg_downg_base.csh >>&! extract_upg_downg_base.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk extract_upg_downg_base.log
