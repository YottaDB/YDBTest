#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -journal=enable,nobefore -reg "*" >&! jnl_on.log
$gtm_exe/mumps -run setup^implicitrlbk
$gtm_tst/$tst/u_inref/jnl_extract.csh > extracted_jnl_data0.logx
$gtm_exe/mumps -run implicitrlbk
$gtm_exe/mumps -run validate^implicitrlbk
$gtm_tst/$tst/u_inref/jnl_extract.csh > extracted_jnl_data1.logx
diff extracted_jnl_data{0,1}.logx | $grep -E '^(<|>)'
echo ""
$gtm_exe/mumps -run implicitrlbk
$gtm_exe/mumps -run validate^implicitrlbk
$gtm_tst/$tst/u_inref/jnl_extract.csh > extracted_jnl_data2.logx
diff extracted_jnl_data{1,2}.logx | $grep -E '^(<|>)'
$echoline
$gtm_tst/com/dbcheck.csh -extract
