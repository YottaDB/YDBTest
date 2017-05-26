#	make_void_caret_old.csh - setup for external call functions using label^routine notation.
#
#	This is the same as make_void_caret.csh except that it declares the function
#	argument types using the xc form of types defined in $gtm_dist/gtmxc_types.h.
#
#	Note: there is no real analogue for the M label^routine notation in C.  This table
#	just creates a plausible mapping between the two.
#
$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_void_caret.c
$gt_ld_shl_linker ${gt_ld_option_output}libvoid_caret_o${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_void_caret.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_void_caret.tab
echo "`pwd`/libvoid_caret_o${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
voidc^caret:		void	xc_void()
inlong^caret:		void	xc_inlong(I:xc_long_t)
inlongp^caret:		void	xc_inlongp(I:xc_long_t *)
inulong^caret:		void	xc_inulong(I:xc_ulong_t)
inulongp^caret:		void	xc_inulongp(I:xc_ulong_t *)
infloatp^caret:		void	xc_infloatp(I:xc_float_t *)
indoublep^caret:	void	xc_indoublep(I:xc_double_t *)
incharp^caret:		void	xc_incharp(I:xc_char_t *)
incharpp^caret:		void	xc_incharpp(I:xc_char_t **)
instringp^caret:	void	xc_instringp(I:xc_string_t *)
inint^caret:		void	xc_inint(I:xc_int_t)
inintp^caret:		void	xc_inintp(I:xc_int_t *)
inuint^caret:		void	xc_inuint(I:xc_uint_t)
inuintp^caret:		void	xc_inuintp(I:xc_uint_t *)
xx
