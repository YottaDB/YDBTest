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
#       make_void_pk_i_old.csh - setup for void functions invoked via package notation.
#
#       This is the same as make_void_pk_i.csh except that it declares the function
#       argument types using the xc form of variable types rather than using the gtm form of the types
#       defined in $gtm_dist/gtmxc_types.h.
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_void_pk_i.c
$gt_ld_shl_linker ${gt_ld_option_output}libvoid_pk_i_o${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_void_pk_i.o $gt_ld_syslibs 

setenv	GTMXC_pk	gtmxc_void_pk_i.tab
echo "`pwd`/libvoid_pk_i_o${gt_ld_shl_suffix}" > $GTMXC_pk
cat >> $GTMXC_pk << xx
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
inint:		void	xc_inint(I:xc_int_t)
inintp:	        void    xc_inintp(I:xc_int_t *)
inuint:	        void	xc_inuint(I:xc_uint_t)
inuintp:	void	xc_inuintp(I:xc_uint_t *)
xx
