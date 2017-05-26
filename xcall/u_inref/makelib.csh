$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/{math_hello.c,math_exp.c,math_sqrt.c}
$gt_ld_shl_linker ${gt_ld_option_output}libmath${gt_ld_shl_suffix} $gt_ld_shl_options math_hello.o math_exp.o math_sqrt.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc.tab
echo "`pwd`/libmath${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
hello:	void	math_hello()
exp:	xc_double_t *math_exp(I:xc_double_t*)
sqrt:	xc_double_t *math_sqrt(I:xc_double_t*)
xx
