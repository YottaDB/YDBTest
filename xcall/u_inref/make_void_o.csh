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
#	make_void_o.csh - setup for void functions taking output arguments.
#       This table maps all the gtm types as defined in $gtm_dist/gtmxc_types.h
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_void_o.c
$gt_ld_shl_linker ${gt_ld_option_output}libvoid_o${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_void_o.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_void_o.tab
echo "`pwd`/libvoid_o${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
void:		void	gtm_void()
outlongp:	void	gtm_outlongp(O:gtm_long_t *)
outulongp:	void	gtm_outulongp(O:gtm_ulong_t *)
outfloatp:	void	gtm_outfloatp(O:gtm_float_t *)
outdoublep:	void	gtm_outdoublep(O:gtm_double_t *)
outcharpp:	void	gtm_outcharpp(O:gtm_char_t **)
outstringp:	void	gtm_outstringp(O:gtm_string_t *[100])
outstringp2:	void	gtm_outstringp2(O:gtm_string_t *[100])
outintp:	void    gtm_outintp(IO:gtm_int_t *)
outuintp:	void	gtm_outuintp(IO:gtm_uint_t *)
xx
