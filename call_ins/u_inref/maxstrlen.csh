#################################################################
#								#
# Copyright 2004, 2013 Fidelity Information Services, Inc	#
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
# max_strlen.csh
#
setenv GTMCI cmm.tab
cat >> $GTMCI << aa
maxstr: void  mmaxstr^mmaxstr(I:gtm_char_t*)
aa
#
#
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/cmaxstrlen.c -I$gtm_dist >& comp.log
$gt_ld_linker $gt_ld_option_output cmaxstrlen $gt_ld_options_common cmaxstrlen.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map
if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
#run cmaxstrlen
cmaxstrlen
unsetenv $GTMCI

