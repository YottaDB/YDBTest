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
# 32args.csh
#
$gtm_exe/mumps $gtm_tst/$tst/inref/greaterThan31charfileshouldnotbecalled.m
setenv GTMCI 32args.tab
cat >> $GTMCI << longtab
32args:  void long^ciargs(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
canbeanylengthhere:  void Morethan^ciargs(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
8charlng:  void Morethan8char^ciargs(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
11entrylent:  void Morethan8charlabel^morethan8charciargs(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
31charlabel:  void P31CharLabel0000000000000000000^morethan8charciargs(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
numlabel:  void 12345678^morethan8charciargs(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
31chartruncate:  void Morethan8charlabel^greaterThan31charfileshouldnotbecalled(I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t,I:gtm_long_t)
longtab

$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/32args.c -I$gtm_dist

$gt_ld_linker $gt_ld_option_output args $gt_ld_options_common 32args.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
args
unsetenv GTMCI
