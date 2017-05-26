#!/usr/local/bin/tcsh -f
#
setenv gtmgbldir "mumps.gld"
@ align_bytes = `expr $test_align \* 512`
if (65024 >= $align_bytes) then
	setenv test_align 128
	set tstjnlstr = `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
	setenv tst_jnl_str $tstjnlstr
endif	
$gtm_tst/com/dbcreate.csh mumps 1 255 32767 65024 10 64
$MUPIP set $tst_jnl_str -reg "*" >&! jnl_on.log
$grep "GTM-I-JNLSTATE" jnl_on.log | sort
$GTM << aaa
d ^biglcgb
aaa
$gtm_tst/com/dbcheck.csh
