$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_shlib.c
$gt_ld_shl_linker ${gt_ld_option_output}libshlib${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_shlib.o $gt_ld_syslibs 
setenv	GTMXC	gtmxc_shlib.tab
echo "`pwd`/libshlib${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
hello:		void	hello()
	GTMSHLIBEXIT = 
xx
