#################################################################
#								#
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# gtmxc_test_types.csh
#
#source $gtm_tst/com/dbcreate.csh mumps 7
setenv GTMCI args1.tab
cat >> $GTMCI << args1tab
gtmxc_test0: void test0^testtypes()
gtmxc_test1: gtm_int_t* test1^testtypes(I:gtm_int_t, I:gtm_int_t *, I:gtm_uint_t, I:gtm_uint_t *, I:gtm_long_t, I:gtm_long_t *, I:gtm_ulong_t, I:gtm_ulong_t *, I:gtm_float_t, I:gtm_float_t *, I:gtm_double_t, I:gtm_double_t *, I:gtm_char_t *, I:gtm_string_t *)
gtmxc_test2: gtm_uint_t* test2^testtypes(I:gtm_int_t, I:gtm_int_t *, I:gtm_uint_t, I:gtm_uint_t *, I:gtm_long_t, I:gtm_long_t *, I:gtm_ulong_t, I:gtm_ulong_t *, I:gtm_float_t, I:gtm_float_t *, I:gtm_double_t, I:gtm_double_t *, I:gtm_char_t *, I:gtm_string_t *)
gtmxc_test3: gtm_long_t* test3^testtypes(I:gtm_int_t, I:gtm_int_t *, I:gtm_uint_t, I:gtm_uint_t *, I:gtm_long_t, I:gtm_long_t *, I:gtm_ulong_t, I:gtm_ulong_t *, I:gtm_float_t, I:gtm_float_t *, I:gtm_double_t, I:gtm_double_t *, I:gtm_char_t *, I:gtm_string_t *)
gtmxc_test4: gtm_ulong_t* test4^testtypes(I:gtm_int_t, I:gtm_int_t *, I:gtm_uint_t, I:gtm_uint_t *, I:gtm_long_t, I:gtm_long_t *, I:gtm_ulong_t, I:gtm_ulong_t *, I:gtm_float_t, I:gtm_float_t *, I:gtm_double_t, I:gtm_double_t *, I:gtm_char_t *, I:gtm_string_t *)
gtmxc_test5: gtm_float_t* test5^testtypes(I:gtm_int_t, I:gtm_int_t *, I:gtm_uint_t, I:gtm_uint_t *, I:gtm_long_t, I:gtm_long_t *, I:gtm_ulong_t, I:gtm_ulong_t *, I:gtm_float_t, I:gtm_float_t *, I:gtm_double_t, I:gtm_double_t *, I:gtm_char_t *, I:gtm_string_t *)
gtmxc_test6: gtm_double_t* test6^testtypes(I:gtm_int_t, I:gtm_int_t *, I:gtm_uint_t, I:gtm_uint_t *, I:gtm_long_t, I:gtm_long_t *, I:gtm_ulong_t, I:gtm_ulong_t *, I:gtm_float_t, I:gtm_float_t *, I:gtm_double_t, I:gtm_double_t *, I:gtm_char_t *, I:gtm_string_t *)
gtmxc_test7: gtm_char_t* test7^testtypes(I:gtm_int_t, I:gtm_int_t *, I:gtm_uint_t, I:gtm_uint_t *, I:gtm_long_t, I:gtm_long_t *, I:gtm_ulong_t, I:gtm_ulong_t *, I:gtm_float_t, I:gtm_float_t *, I:gtm_double_t, I:gtm_double_t *, I:gtm_char_t *, I:gtm_string_t *)
gtmxc_test8: gtm_string_t* test8^testtypes(I:gtm_int_t, I:gtm_int_t *, I:gtm_uint_t, I:gtm_uint_t *, I:gtm_long_t, I:gtm_long_t *, I:gtm_ulong_t, I:gtm_ulong_t *, I:gtm_float_t, I:gtm_float_t *, I:gtm_double_t, I:gtm_double_t *, I:gtm_char_t *, I:gtm_string_t *)
gtmxc_test9: gtm_int_t* test9^testtypes(IO:gtm_int_t *, IO:gtm_uint_t *, IO:gtm_long_t *, IO:gtm_ulong_t *, IO:gtm_float_t *, IO:gtm_double_t *, IO:gtm_char_t *, IO:gtm_string_t *)
gtmxc_test10: gtm_uint_t* test10^testtypes(IO:gtm_int_t *, IO:gtm_uint_t *, IO:gtm_long_t *, IO:gtm_ulong_t *, IO:gtm_float_t *, IO:gtm_double_t *, IO:gtm_char_t *, IO:gtm_string_t *)
gtmxc_test11: gtm_long_t* test11^testtypes(IO:gtm_int_t *, IO:gtm_uint_t *, IO:gtm_long_t *, IO:gtm_ulong_t *, IO:gtm_float_t *, IO:gtm_double_t *, IO:gtm_char_t *, IO:gtm_string_t *)
gtmxc_test12: gtm_ulong_t* test12^testtypes(IO:gtm_int_t *, IO:gtm_uint_t *, IO:gtm_long_t *, IO:gtm_ulong_t *, IO:gtm_float_t *, IO:gtm_double_t *, IO:gtm_char_t *, IO:gtm_string_t *)
gtmxc_test13: gtm_float_t* test13^testtypes(IO:gtm_int_t *, IO:gtm_uint_t *, IO:gtm_long_t *, IO:gtm_ulong_t *, IO:gtm_float_t *, IO:gtm_double_t *, IO:gtm_char_t *, IO:gtm_string_t *)
gtmxc_test14: gtm_double_t* test14^testtypes(IO:gtm_int_t *, IO:gtm_uint_t *, IO:gtm_long_t *, IO:gtm_ulong_t *, IO:gtm_float_t *, IO:gtm_double_t *, IO:gtm_char_t *, IO:gtm_string_t *)
gtmxc_test15: gtm_char_t* test15^testtypes(IO:gtm_int_t *, IO:gtm_uint_t *, IO:gtm_long_t *, IO:gtm_ulong_t *, IO:gtm_float_t *, IO:gtm_double_t *, IO:gtm_char_t *, IO:gtm_string_t *)
gtmxc_test16: gtm_string_t* test16^testtypes(IO:gtm_int_t *, IO:gtm_uint_t *, IO:gtm_long_t *, IO:gtm_ulong_t *, IO:gtm_float_t *, IO:gtm_double_t *, IO:gtm_char_t *, IO:gtm_string_t *)
gtmxc_test17: gtm_int_t* test17^testtypes(O:gtm_int_t *, O:gtm_uint_t *, O:gtm_long_t *, O:gtm_ulong_t *, O:gtm_float_t *, O:gtm_double_t *, O:gtm_char_t *, O:gtm_string_t *)
gtmxc_test18: gtm_uint_t* test18^testtypes(O:gtm_int_t *, O:gtm_uint_t *, O:gtm_long_t *, O:gtm_ulong_t *, O:gtm_float_t *, O:gtm_double_t *, O:gtm_char_t *, O:gtm_string_t *)
gtmxc_test19: gtm_long_t* test19^testtypes(O:gtm_int_t *, O:gtm_uint_t *, O:gtm_long_t *, O:gtm_ulong_t *, O:gtm_float_t *, O:gtm_double_t *, O:gtm_char_t *, O:gtm_string_t *)
gtmxc_test20: gtm_ulong_t* test20^testtypes(O:gtm_int_t *, O:gtm_uint_t *, O:gtm_long_t *, O:gtm_ulong_t *, O:gtm_float_t *, O:gtm_double_t *, O:gtm_char_t *, O:gtm_string_t *)
gtmxc_test21: gtm_float_t* test21^testtypes(O:gtm_int_t *, O:gtm_uint_t *, O:gtm_long_t *, O:gtm_ulong_t *, O:gtm_float_t *, O:gtm_double_t *, O:gtm_char_t *, O:gtm_string_t *)
gtmxc_test22: gtm_double_t* test22^testtypes(O:gtm_int_t *, O:gtm_uint_t *, O:gtm_long_t *, O:gtm_ulong_t *, O:gtm_float_t *, O:gtm_double_t *, O:gtm_char_t *, O:gtm_string_t *)
gtmxc_test23: gtm_char_t* test23^testtypes(O:gtm_int_t *, O:gtm_uint_t *, O:gtm_long_t *, O:gtm_ulong_t *, O:gtm_float_t *, O:gtm_double_t *, O:gtm_char_t *, O:gtm_string_t *)
gtmxc_test24: gtm_string_t* test24^testtypes(O:gtm_int_t *, O:gtm_uint_t *, O:gtm_long_t *, O:gtm_ulong_t *, O:gtm_float_t *, O:gtm_double_t *, O:gtm_char_t *, O:gtm_string_t *)
args1tab
#
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_test_types.c
$gt_ld_linker $gt_ld_option_output gtmxc_test_types $gt_ld_options_common gtmxc_test_types.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map

if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
gtmxc_test_types


echo "### Now test that various other types are treated as invalid"
echo "Detail results in gtmxc_test_types.invalid\n"

# List of types to test for invalidity
set types = "gtm_int_t gtm_uint_t gtm_long_t gtm_ulong_t gtm_float_t gtm_double_t gtm_char_t gtm_string_t ydb_buffer_t"
set types = "$types gtm_char_tPP gtm_pointertofunc_t gtm_status_t"
set types = "$types ydb_jboolean ydb_jint ydb_jlong ydb_jfloat ydb_jdouble ydb_jstring ydb_jbyte_array ydb_jbig_decimal"

# Loop through types, testing that each is invalid
echo >! gtmxc_test_types.invalid  # Clear test result artifact
foreach type ( $types )
    echo "\nTesting that type $type is invalid"
    echo "\nTesting that type $type is invalid" >> gtmxc_test_types.invalid
    setenv GTMCI "args2-$type.tab"
    echo >! "$GTMCI" "gtmxc_test0: $type:as/P/*/ test0^testtypes()"
    gtmxc_test_types >& gtmxc_test_types.invalid.tmp
    cat gtmxc_test_types.invalid.tmp >> gtmxc_test_types.invalid  # Add to complete test result artifact
    cat gtmxc_test_types.invalid.tmp | grep -o "CIRTNTYP.*Invalid return type"
end

unsetenv GTMCI
#$gtm_tst/com/dbcheck.csh -extract
