# 
# maxnestlvl.csh
# 
# call in
setenv GTMCI `pwd`/main.tab
cat >> $GTMCI << maintab
entry1: void entry1^test()
entry2: void entry2^test(I:gtm_long_t, I:gtm_long_t, O:gtm_long_t*, I:gtm_long_t, I:gtm_long_t)
entry3: void err^test()
main: void main^test()
maintab
#
$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/$tst/inref -I$gtm_dist $gtm_tst/$tst/inref/callc.c
$gt_ld_shl_linker ${gt_ld_option_output}libcallc${gt_ld_shl_suffix} $gt_ld_shl_options callc.o $tst_ld_sidedeck >&! link1.map

if( $status != 0 ) then
    cat link1.map
endif

rm -f link1.map
rm -f callc.o

#
# external call
#
setenv  GTMXC_xcall `pwd`/tst.tab
echo "`pwd`/libcallc${gt_ld_shl_suffix}" > $GTMXC_xcall
cat >> $GTMXC_xcall << xx
callc:  xc_status_t callc(I:xc_long_t, I:xc_long_t, O:xc_long_t*)
xx

$gt_cc_compiler $gt_cc_options_common $gtm_tst/$tst/inref/main.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output dmain $gt_ld_options_common main.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >&! link2.map

if( $status != 0 ) then
    cat link2.map
endif
rm -f link2.map

dmain
unsetenv $GTMCI
unsetenv $GTMXC_xcall

