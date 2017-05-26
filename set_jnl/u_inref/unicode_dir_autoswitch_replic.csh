#!/usr/local/bin/tcsh -f
# This applies to replication only
$switch_chset UTF-8

# switch_chset is done before calling the subtests containing unicode characters
# If this is not done, the subtests fail to understand the unicode characters properly in HP-UX and solaris

# Since we know that this test uses low autoswitch limits we only need the align size for 2.5 MBs.
# This should be removed when C9D06-002283 is fixed.
if ($test_align > 8192) then
	setenv test_align 8192
	set tstjnlstr = `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
	setenv tst_jnl_str $tstjnlstr
endif

$gtm_tst/$tst/u_inref/unicode_dir_autoswitch_replic_base.csh
