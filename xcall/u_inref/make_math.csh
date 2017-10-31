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
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/{math_xcall.c}
$gt_ld_shl_linker ${gt_ld_option_output}libxmath${gt_ld_shl_suffix} $gt_ld_shl_options math_xcall.o $gt_ld_syslibs 

setenv GTMXC "gtmxc_math.tab"
setenv  my_shlib_path `pwd`
echo '$my_shlib_path'"/libxmath${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
GTMSHLIBEXIT   =   cleanup  
hello:	void math_hello()
xexp: 	void xexp(I:xc_string_t *,I:xc_long_t,IO:xc_string_t *)
xsqrt: 	void xsqrt(I:xc_string_t *,I:xc_long_t,IO:xc_string_t *)
logb10: void logb10(I:xc_string_t *,I:xc_long_t,IO:xc_string_t *)
logb10l: void logb10forrealbignamesupto31(I:xc_string_t *,I:xc_long_t,IO:xc_string_t *)
xsqrtlonglabelforsqaurerootchk: void xsqrt(I:xc_string_t *,I:xc_long_t,IO:xc_string_t *)
lognat: void lognat(I:xc_string_t *,I:xc_long_t,IO:xc_string_t *)
 GTMSHLIBEXIT   =   cleanup  This will overwrite previous entry details
xx
