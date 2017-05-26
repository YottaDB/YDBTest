#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 >>& switch_chset.out

# switch_chset is done before calling the subtests containing unicode characters
# If this is not done, the subtests fail to understand the unicode characters properly in HP-UX and solaris

$gtm_tst/$tst/u_inref/shared_lib_unicode_zb_base.csh
