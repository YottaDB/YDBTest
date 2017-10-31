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
# xc_test_types.csh
# 
#source $gtm_tst/com/dbcreate.csh mumps 7
setenv GTMCI args1.tab
cat >> $GTMCI << args1tab
xc_test1: xc_int_t* test1^testtypes(I:xc_int_t, I:xc_int_t *, I:xc_uint_t, I:xc_uint_t *, I:xc_long_t, I:xc_long_t *, I:xc_ulong_t, I:xc_ulong_t *, I:xc_float_t, I:xc_float_t *, I:xc_double_t, I:xc_double_t *, I:xc_char_t *, I:xc_string_t *)
xc_test2: xc_uint_t* test2^testtypes(I:xc_int_t, I:xc_int_t *, I:xc_uint_t, I:xc_uint_t *, I:xc_long_t, I:xc_long_t *, I:xc_ulong_t, I:xc_ulong_t *, I:xc_float_t, I:xc_float_t *, I:xc_double_t, I:xc_double_t *, I:xc_char_t *, I:xc_string_t *)
xc_test3: xc_long_t* test3^testtypes(I:xc_int_t, I:xc_int_t *, I:xc_uint_t, I:xc_uint_t *, I:xc_long_t, I:xc_long_t *, I:xc_ulong_t, I:xc_ulong_t *, I:xc_float_t, I:xc_float_t *, I:xc_double_t, I:xc_double_t *, I:xc_char_t *, I:xc_string_t *)
xc_test4: xc_ulong_t* test4^testtypes(I:xc_int_t, I:xc_int_t *, I:xc_uint_t, I:xc_uint_t *, I:xc_long_t, I:xc_long_t *, I:xc_ulong_t, I:xc_ulong_t *, I:xc_float_t, I:xc_float_t *, I:xc_double_t, I:xc_double_t *, I:xc_char_t *, I:xc_string_t *)
xc_test5: xc_float_t* test5^testtypes(I:xc_int_t, I:xc_int_t *, I:xc_uint_t, I:xc_uint_t *, I:xc_long_t, I:xc_long_t *, I:xc_ulong_t, I:xc_ulong_t *, I:xc_float_t, I:xc_float_t *, I:xc_double_t, I:xc_double_t *, I:xc_char_t *, I:xc_string_t *)
xc_test6: xc_double_t* test6^testtypes(I:xc_int_t, I:xc_int_t *, I:xc_uint_t, I:xc_uint_t *, I:xc_long_t, I:xc_long_t *, I:xc_ulong_t, I:xc_ulong_t *, I:xc_float_t, I:xc_float_t *, I:xc_double_t, I:xc_double_t *, I:xc_char_t *, I:xc_string_t *)
xc_test7: xc_char_t* test7^testtypes(I:xc_int_t, I:xc_int_t *, I:xc_uint_t, I:xc_uint_t *, I:xc_long_t, I:xc_long_t *, I:xc_ulong_t, I:xc_ulong_t *, I:xc_float_t, I:xc_float_t *, I:xc_double_t, I:xc_double_t *, I:xc_char_t *, I:xc_string_t *)
xc_test8: xc_string_t* test8^testtypes(I:xc_int_t, I:xc_int_t *, I:xc_uint_t, I:xc_uint_t *, I:xc_long_t, I:xc_long_t *, I:xc_ulong_t, I:xc_ulong_t *, I:xc_float_t, I:xc_float_t *, I:xc_double_t, I:xc_double_t *, I:xc_char_t *, I:xc_string_t *)
xc_test9: xc_int_t* test9^testtypes(IO:xc_int_t *, IO:xc_uint_t *, IO:xc_long_t *, IO:xc_ulong_t *, IO:xc_float_t *, IO:xc_double_t *, IO:xc_char_t *, IO:xc_string_t *)
xc_test10: xc_uint_t* test10^testtypes(IO:xc_int_t *, IO:xc_uint_t *, IO:xc_long_t *, IO:xc_ulong_t *, IO:xc_float_t *, IO:xc_double_t *, IO:xc_char_t *, IO:xc_string_t *)
xc_test11: xc_long_t* test11^testtypes(IO:xc_int_t *, IO:xc_uint_t *, IO:xc_long_t *, IO:xc_ulong_t *, IO:xc_float_t *, IO:xc_double_t *, IO:xc_char_t *, IO:xc_string_t *)
xc_test12: xc_ulong_t* test12^testtypes(IO:xc_int_t *, IO:xc_uint_t *, IO:xc_long_t *, IO:xc_ulong_t *, IO:xc_float_t *, IO:xc_double_t *, IO:xc_char_t *, IO:xc_string_t *)
xc_test13: xc_float_t* test13^testtypes(IO:xc_int_t *, IO:xc_uint_t *, IO:xc_long_t *, IO:xc_ulong_t *, IO:xc_float_t *, IO:xc_double_t *, IO:xc_char_t *, IO:xc_string_t *)
xc_test14: xc_double_t* test14^testtypes(IO:xc_int_t *, IO:xc_uint_t *, IO:xc_long_t *, IO:xc_ulong_t *, IO:xc_float_t *, IO:xc_double_t *, IO:xc_char_t *, IO:xc_string_t *)
xc_test15: xc_char_t* test15^testtypes(IO:xc_int_t *, IO:xc_uint_t *, IO:xc_long_t *, IO:xc_ulong_t *, IO:xc_float_t *, IO:xc_double_t *, IO:xc_char_t *, IO:xc_string_t *)
xc_test16: xc_string_t* test16^testtypes(IO:xc_int_t *, IO:xc_uint_t *, IO:xc_long_t *, IO:xc_ulong_t *, IO:xc_float_t *, IO:xc_double_t *, IO:xc_char_t *, IO:xc_string_t *)
xc_test17: xc_int_t* test17^testtypes(O:xc_int_t *, O:xc_uint_t *, O:xc_long_t *, O:xc_ulong_t *, O:xc_float_t *, O:xc_double_t *, O:xc_char_t *, O:xc_string_t *)
xc_test18: xc_uint_t* test18^testtypes(O:xc_int_t *, O:xc_uint_t *, O:xc_long_t *, O:xc_ulong_t *, O:xc_float_t *, O:xc_double_t *, O:xc_char_t *, O:xc_string_t *)
xc_test19: xc_long_t* test19^testtypes(O:xc_int_t *, O:xc_uint_t *, O:xc_long_t *, O:xc_ulong_t *, O:xc_float_t *, O:xc_double_t *, O:xc_char_t *, O:xc_string_t *)
xc_test20: xc_ulong_t* test20^testtypes(O:xc_int_t *, O:xc_uint_t *, O:xc_long_t *, O:xc_ulong_t *, O:xc_float_t *, O:xc_double_t *, O:xc_char_t *, O:xc_string_t *)
xc_test21: xc_float_t* test21^testtypes(O:xc_int_t *, O:xc_uint_t *, O:xc_long_t *, O:xc_ulong_t *, O:xc_float_t *, O:xc_double_t *, O:xc_char_t *, O:xc_string_t *)
xc_test22: xc_double_t* test22^testtypes(O:xc_int_t *, O:xc_uint_t *, O:xc_long_t *, O:xc_ulong_t *, O:xc_float_t *, O:xc_double_t *, O:xc_char_t *, O:xc_string_t *)
xc_test23: xc_char_t* test23^testtypes(O:xc_int_t *, O:xc_uint_t *, O:xc_long_t *, O:xc_ulong_t *, O:xc_float_t *, O:xc_double_t *, O:xc_char_t *, O:xc_string_t *)
xc_test24: xc_string_t* test24^testtypes(O:xc_int_t *, O:xc_uint_t *, O:xc_long_t *, O:xc_ulong_t *, O:xc_float_t *, O:xc_double_t *, O:xc_char_t *, O:xc_string_t *)
args1tab
#
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/xc_test_types.c
$gt_ld_linker $gt_ld_option_output xc_test_types $gt_ld_options_common xc_test_types.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map

if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
xc_test_types
unsetenv $GTMCI
#$gtm_tst/com/dbcheck.csh -extract


