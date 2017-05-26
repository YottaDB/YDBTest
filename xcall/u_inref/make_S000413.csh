#	make_S000413.csh - setup for void functions taking multiple input arguments.
#
$gt_cc_compiler $gt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/S000413.c
$gt_ld_shl_linker ${gt_ld_option_output}libS000413${gt_ld_shl_suffix} $gt_ld_shl_options S000413.o $gt_ld_syslibs 

\rm S000413.o

setenv	GTMXC	S000413.tab
echo "`pwd`/libS000413${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
inmult:		void	xc_inmult(I:xc_long_t, I:xc_long_t *, I:xc_ulong_t, I:xc_ulong_t *, I:xc_int_t, I:xc_int_t *, I:xc_uint_t, I:xc_uint_t *, I:xc_float_t *, I:xc_double_t *, I:xc_char_t *, I:xc_char_t **, I:xc_string_t *)
xx
