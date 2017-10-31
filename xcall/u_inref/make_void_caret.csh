#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#	make_void_caret.csh - setup for external call functions using label^routine notation.
#
#	Note: there is no real analogue for the M label^routine notation in C; this table
#	just creates a plausible mapping between the two.
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_void_caret.c
$gt_ld_shl_linker ${gt_ld_option_output}libvoid_caret${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_void_caret.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_void_caret.tab
echo "`pwd`/libvoid_caret${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
voidc^caret:		void	gtm_void()
inlong^caret:		void	gtm_inlong(I:gtm_long_t)
inlongp^caret:		void	gtm_inlongp(I:gtm_long_t *)
inulong^caret:		void	gtm_inulong(I:gtm_ulong_t)
inulongp^caret:		void	gtm_inulongp(I:gtm_ulong_t *)
infloatp^caret:		void	gtm_infloatp(I:gtm_float_t *)
indoublep^caret:	void	gtm_indoublep(I:gtm_double_t *)
incharp^caret:		void	gtm_incharp(I:gtm_char_t *)
incharpp^caret:		void	gtm_incharpp(I:gtm_char_t **)
instringp^caret:	void	gtm_instringp(I:gtm_string_t *)
inint^caret:		void	gtm_inint(I:gtm_int_t)
inintp^caret:		void	gtm_inintp(I:gtm_int_t *)
inuint^caret:		void	gtm_inuint(I:gtm_uint_t)
inuintp^caret:		void	gtm_inuintp(I:gtm_uint_t *)
xx
