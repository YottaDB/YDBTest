#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Tests call ins and external calls involving the new ydb_int64_t and ydb_uint64_t types
#
# call in to M from C
#
setenv ydb_ci cmcm.tab
cat >> $ydb_ci << xx
sqroot:  void  sqroot^ydb518m(I:ydb_int64_t,I:ydb_int64_t)
cube:    ydb_int64_t* cubeit^ydb518m(I:ydb_int64_t)
usqroot: void sqroot^ydb518m(I:ydb_uint64_t,I:ydb_uint64_t)
ucube:   ydb_uint64_t* cubeit^ydb518m(I:ydb_uint64_t)
xx
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/squarec.c
$gt_ld_shl_linker ${gt_ld_option_output}libsquare${gt_ld_shl_suffix} $gt_ld_shl_options squarec.o $gt_ld_syslibs >&! link1.map
if( $status != 0 ) then
    cat link1.map
endif

rm -f  link1.map
rm -f squarec.o

#
# external call to C from M
#
setenv  ydb_xc   mcm.tab
echo "`pwd`/libsquare${gt_ld_shl_suffix}" > $ydb_xc
cat >> $ydb_xc << xxx
squarec:  ydb_int64_t   squarec(I:ydb_int64_t)
usquarec: ydb_uint64_t  usquarec(I:ydb_uint64_t)
xxx

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/ydb518.c
$gt_ld_linker $gt_ld_option_output ydb518 $gt_ld_options_common ydb518.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >&! link2.map
if( $status != 0 ) then
    cat link2.map
endif
rm -f link2.map

`pwd`/ydb518
unsetenv ydb_ci
unsetenv ydb_xc
