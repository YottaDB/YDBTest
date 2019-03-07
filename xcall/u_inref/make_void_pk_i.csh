#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#	make_void_pk_i.csh - setup for void functions invoked via package notation.
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_void_pk_i.c
$gt_ld_shl_linker ${gt_ld_option_output}libvoid_pk_i${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_void_pk_i.o $gt_ld_syslibs 

setenv	GTMXC_pk	gtmxc_void_pk_i.tab
echo "`pwd`/libvoid_pk_i${gt_ld_shl_suffix}" > $GTMXC_pk
cat >> $GTMXC_pk << xx
void:		void	gtm_void()
inlong:		void	gtm_inlong(I:gtm_long_t)
inlongp:	void	gtm_inlongp(I:gtm_long_t *)
inulong:	void	gtm_inulong(I:gtm_ulong_t)
inulongp:	void	gtm_inulongp(I:gtm_ulong_t *)
infloatp:	void	gtm_infloatp(I:gtm_float_t *)
indoublep:	void	gtm_indoublep(I:gtm_double_t *)
incharp:	void	gtm_incharp(I:gtm_char_t *)
incharpp:	void	gtm_incharpp(I:gtm_char_t **)
instringp:	void	gtm_instringp(I:gtm_string_t *)
inint:		void	gtm_inint(I:gtm_int_t)
inintp:	        void    gtm_inintp(I:gtm_int_t *)
inuint:	        void	gtm_inuint(I:gtm_uint_t)
inuintp:	void	gtm_inuintp(I:gtm_uint_t *)
xx
