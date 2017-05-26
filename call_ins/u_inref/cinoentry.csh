# cinoentry.csh
# 
setenv GTMCI noent.tab
cat >> $GTMCI << cintab
build:   void^build()
get: gtm_char_t* ccode^getrec2(I:gtm_long_t)
cintab

source $gtm_tst/com/dbcreate.csh mumps

$gt_cc_compiler $gt_cc_options_common $gtm_tst/$tst/inref/gtmci_tberrs.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output ccnoent $gt_ld_options_common gtmci_tberrs.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map

if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
source $gtm_tst/com/dbcheck.csh








