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
#       make_void_o_old.csh - setup for void functions taking output arguments.
#
#       This is the same as make_void_o.csh except that it declares the function
#       argument types using native C variable types rather than using the types
#       defined in $gtm_dist/gtmxc_types.h.
#       This is to test that we still support the undocumented types we used to
#       support in earlier releases of the Unix external call mechanism for
#       backward compatibility with old releases sent to Sanchez Computer
#       Associates (SCA).
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_void_o.c
$gt_ld_shl_linker ${gt_ld_option_output}libvoid_o_o${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_void_o.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_void_o.tab
echo "`pwd`/libvoid_o_o${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
void:		void	xc_void()
outlongp:	void	xc_outlongp(O:xc_long_t *)
outulongp:	void	xc_outulongp(O:xc_ulong_t *)
outfloatp:	void	xc_outfloatp(O:xc_float_t *)
outdoublep:	void	xc_outdoublep(O:xc_double_t *)
outcharpp:	void	xc_outcharpp(O:xc_char_t **)
outstringp:	void	xc_outstringp(O:xc_string_t *[100])
outstringp2:	void	xc_outstringp2(O:xc_string_t *[100])
outintp:	void    xc_outintp(IO:xc_int_t *)
outuintp:	void	xc_outuintp(IO:xc_uint_t *)
xx
