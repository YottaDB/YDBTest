#
$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_uniprealloc.c
$gt_ld_shl_linker ${gt_ld_option_output}libuniprealloc${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_uniprealloc.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_uniprealloc.tab
echo "`pwd`/libuniprealloc${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
prealloc^correct:	void	xc_pre_alloc_a(O:xc_char_t *[])
alloc32k:	void	xc_new_alloc_32k(O:xc_char_t *[32768])
alloc64k:	void	xc_new_alloc_64k(O:xc_char_t *[65536])
alloc75k:	void	xc_new_alloc_75k(O:xc_char_t *[75000])
alloc1mb:	void	xc_new_alloc_1mb(O:xc_char_t *[1048576])
xx
