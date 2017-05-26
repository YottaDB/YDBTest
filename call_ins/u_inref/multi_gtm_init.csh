#!/usr/local/bin/tcsh -f
# 
# multi_gtm_init.csh
# 
setenv GTMCI cmm.tab
cat >> $GTMCI << cmm.tab
square:gtm_long_t*  squar^square(I:gtm_long_t)
cmm.tab
#
#

$gt_cc_compiler $gt_cc_options_common -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/multi_init.c
$gt_ld_linker $gt_ld_option_output multi $gt_ld_options_common multi_init.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map
if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
multi
unsetenv $GTMCI

