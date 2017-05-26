$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_oops.c
$gt_ld_shl_linker ${gt_ld_option_output}liboops${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_oops.o $gt_ld_syslibs 
setenv	GTMXC	gtmxc_oops.tab
echo "`pwd`/liboops${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
hello:		void	xc_hello()
oops:		void	xc_oops(I:xc_long_t, I:xc_long_t)
xx
