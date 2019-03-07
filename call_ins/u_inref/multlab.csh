#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# checking for long entryrefs,labels,filenames
# multlab.csh
#
$gtm_exe/mumps $gtm_tst/$tst/inref/multlabm.m
setenv GTMCI multlab.tab
cat >> $GTMCI << longtab
truncated31:  void Greaterthan31charlabelshouldnot^multlabm(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
morethan31:  void Greaterthan31charlabelshouldnotbecalled^multlabm(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
longtab

$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/multlab.c -I$gtm_dist

$gt_ld_linker $gt_ld_option_output multlab $gt_ld_options_common multlab.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map

if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
echo "Two calls both should go to Greaterthan31charlabelshouldnot^multlabm"
multlab
unsetenv GTMCI
