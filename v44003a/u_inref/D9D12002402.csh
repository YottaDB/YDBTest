#!/usr/local/bin/tcsh
#
# D9D12-002402 TID in the journal extract seems to be from innermost TSTART not outermost
#
$gtm_tst/com/dbcreate.csh mumps
$MUPIP set $tst_jnl_str -region "*" >&! mupip_set_jnl.out
$grep "GTM-I-JNLSTATE" mupip_set_jnl.out
$GTM <<GTM_EOF
	do ^d002402
GTM_EOF
$MUPIP journal -extract -noverify -forward -fences=none mumps.mjl
echo "------------------------------------"
echo "List of tids in journal extract file"
echo "------------------------------------"
$tst_awk -f $gtm_tst/$tst/inref/D9D12002402.awk mumps.mjf
$gtm_tst/com/dbcheck.csh
