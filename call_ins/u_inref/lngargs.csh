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
#
# lngargs.csh
#
setenv GTMCI lngargs.tab

cat >> $GTMCI << longtab
toolong:  void toolong^ciargs(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
longtab

$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/gtmci_lngargs.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output lngargs $gt_ld_options_common gtmci_lngargs.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map
if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
lngargs
unsetenv GTMCI




