#!/usr/local/bin/tcsh -f
if ($#argv != 2 ) then
	echo "check_col_nct_chn.csh expects exactly two parameters: nct, act"
	echo "for example: check_col_nct_chn.csh 1 1 ==> zwr and compare with col_nct_chn_1_1.txt"
	echo "             check_col_nct_chn.csh 0 1 ==> zwr and compare with col_nct_chn_0_1.txt"
	exit 1
endif

$GTM << \aaa >& col_nct_chn_$1_$2.out
zwr ^a
\aaa

diff $gtm_tst/$tst/inref/col_nct_chn_$1_$2.txt col_nct_chn_$1_$2.out >& col_nct_chn_$1_$2.diff
if $status then
	echo "Checking scenario with nct :: $1 and act :: $2 FAILED"
	echo "Check col_nct_chn_$1_$2.diff"
else
	echo "Checking scenario with nct :: $1 and act :: $2 PASSED"
endif
