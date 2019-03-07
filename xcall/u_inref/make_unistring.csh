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
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_unistring.c >& comp.log
if ($status) then
	echo "TEST-E-ERROR in compiling gtmxc_unistring.c"
	cat comp.log
endif
$gt_ld_shl_linker ${gt_ld_option_output}libxunistring${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_unistring.o $gt_ld_syslibs 

setenv GTMXC "gtmxc_unistring.tab"
echo "`pwd`/libxunistring${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
wcslen: 	void xc_wcslen(I:xc_char_t **,IO:xc_string_t *)
wcscat:		void xc_wcscat(I:xc_char_t **, I:xc_char_t **, IO:xc_char_t **)
wcscpy:		void xc_wcscpy(I:xc_char_t **,IO:xc_char_t **)
xx
