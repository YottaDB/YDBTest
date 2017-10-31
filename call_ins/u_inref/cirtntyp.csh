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
# cirtntyp.csh
#
setenv GTMCI rtntyp.tab
cat >> $GTMCI << rtntytab
getcode: gtm_char_t  ccode^getrec2(I:gtm_long_t)
rtntytab

$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/gtmci_tberrs.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output crtntyp $gt_ld_options_common gtmci_tberrs.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map

if( $status != 0 ) then
    cat link.map
endif
if ( -e /usr/local/bin/execstack ) then
    /usr/local/bin/execstack -s crtntyp
endif

rm -f  link.map
