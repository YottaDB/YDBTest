$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/{math_xcall.c}
$gt_ld_shl_linker ${gt_ld_option_output}libxmath${gt_ld_shl_suffix} $gt_ld_shl_options math_xcall.o $gt_ld_syslibs >& make_math_ld.outx 

setenv GTMXC "gtmxc_math.tab"
echo "`pwd`/libxmath${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
xexp: 	void xexp(I:xc_char_t *,I:xc_long_t,IO:xc_char_t *)
xsqrt: 	void xsqrt(I:xc_char_t *,I:xc_long_t,IO:xc_char_t *)
logb10: void logb10(I:xc_char_t *,I:xc_long_t,IO:xc_char_t *)
logb10l: void logb10forrealbignamesupto31(I:xc_char_t *,I:xc_long_t,IO:xc_char_t *)
xsqrtlonglabelforsqaurerootchk: void xsqrt(I:xc_char_t *,I:xc_long_t,IO:xc_char_t *)
lognat: void lognat(I:xc_char_t *,I:xc_long_t,IO:xc_char_t *)
xx
