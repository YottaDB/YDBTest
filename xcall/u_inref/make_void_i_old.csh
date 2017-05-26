#	make_void_i_old.csh - setup for void functions taking input arguments.
#
#	This is the same as make_void_i.csh except that it declares the function
#	argument types using native C variable types rather than using the types
#	defined in $gtm_dist/gtmxc_types.h.
#	This is to test that we still support the undocumented types we used to
#	support in earlier releases of the Unix external call mechanism for
#	backward compatibility with old releases sent to Sanchez Computer
#	Associates (SCA).
#
$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_void_i.c
$gt_ld_shl_linker ${gt_ld_option_output}lib_void_i_o${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_void_i.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_void_i.tab
echo "`pwd`/lib_void_i_o${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
void:		void	xc_void()
inlong:		void	xc_inlong(I:xc_long_t)
inlongp:	void	xc_inlongp(I:xc_long_t *)
inulong:	void	xc_inulong(I:xc_ulong_t)
inulongp:	void	xc_inulongp(I:xc_ulong_t *)
infloatp:	void	xc_infloatp(I:xc_float_t *)
indoublep:	void	xc_indoublep(I:xc_double_t *)
incharp:	void	xc_incharp(I:xc_char_t *)
incharpp:	void	xc_incharpp(I:xc_char_t **)
instringp:	void	xc_instringp(I:xc_string_t *)
inint:	        void	xc_inint(IO:xc_int_t)
inintp:	        void	xc_inintp(IO:xc_int_t *)
inuint: 	void	xc_inuint(IO:xc_uint_t)
inuintp:	void	xc_inuintp(IO:xc_uint_t *)
xx
