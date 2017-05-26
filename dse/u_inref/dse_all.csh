# Test dse -all
set dse_awkfile=$gtm_tst/$tst/u_inref/awkfile.awk
$tst_tcsh $gtm_tst/$tst/u_inref/all.csh >&! all_proc_spec
$tst_awk -f $dse_awkfile all_proc_spec
unset dse_awkfile
