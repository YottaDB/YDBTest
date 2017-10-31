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
#	make__void_i.csh - setup for void functions taking input arguments.
#       This table maps all the gtm types as defined in $gtm_dist/gtmxc_types.h
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_void_i.c
$gt_ld_shl_linker ${gt_ld_option_output}libvoid_i${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_void_i.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_void_i.tab
echo "`pwd`/libvoid_i${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
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
inint:	        void	gtm_inint(IO:gtm_int_t)
inintp:	        void    gtm_inintp(IO:gtm_int_t *)
inuint:         void    gtm_inuint(IO:gtm_uint_t)
inuintp:	void	gtm_inuintp(IO:gtm_uint_t *)
xx
