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

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$ydb_dist $gtm_tst/$tst/inref/ydbxc_test_types.c
$gt_ld_linker $gt_ld_option_output ydbxc_test_types $gt_ld_options_common ydbxc_test_types.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map

if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map


echo "### Start the tests for ydb_*_t types"
setenv GTMCI args1.tab
cat >> $GTMCI << args1tab
ydbxc_test0: void test0^testtypes()
ydbxc_test1: ydb_int_t* test1^testtypes(I:ydb_int_t, I:ydb_int_t *, I:ydb_uint_t, I:ydb_uint_t *, I:ydb_long_t, I:ydb_long_t *, I:ydb_ulong_t, I:ydb_ulong_t *, I:ydb_float_t, I:ydb_float_t *, I:ydb_double_t, I:ydb_double_t *, I:ydb_char_t *, I:ydb_string_t *)
ydbxc_test2: ydb_uint_t* test2^testtypes(I:ydb_int_t, I:ydb_int_t *, I:ydb_uint_t, I:ydb_uint_t *, I:ydb_long_t, I:ydb_long_t *, I:ydb_ulong_t, I:ydb_ulong_t *, I:ydb_float_t, I:ydb_float_t *, I:ydb_double_t, I:ydb_double_t *, I:ydb_char_t *, I:ydb_string_t *)
ydbxc_test3: ydb_long_t* test3^testtypes(I:ydb_int_t, I:ydb_int_t *, I:ydb_uint_t, I:ydb_uint_t *, I:ydb_long_t, I:ydb_long_t *, I:ydb_ulong_t, I:ydb_ulong_t *, I:ydb_float_t, I:ydb_float_t *, I:ydb_double_t, I:ydb_double_t *, I:ydb_char_t *, I:ydb_string_t *)
ydbxc_test4: ydb_ulong_t* test4^testtypes(I:ydb_int_t, I:ydb_int_t *, I:ydb_uint_t, I:ydb_uint_t *, I:ydb_long_t, I:ydb_long_t *, I:ydb_ulong_t, I:ydb_ulong_t *, I:ydb_float_t, I:ydb_float_t *, I:ydb_double_t, I:ydb_double_t *, I:ydb_char_t *, I:ydb_string_t *)
ydbxc_test5: ydb_float_t* test5^testtypes(I:ydb_int_t, I:ydb_int_t *, I:ydb_uint_t, I:ydb_uint_t *, I:ydb_long_t, I:ydb_long_t *, I:ydb_ulong_t, I:ydb_ulong_t *, I:ydb_float_t, I:ydb_float_t *, I:ydb_double_t, I:ydb_double_t *, I:ydb_char_t *, I:ydb_string_t *)
ydbxc_test6: ydb_double_t* test6^testtypes(I:ydb_int_t, I:ydb_int_t *, I:ydb_uint_t, I:ydb_uint_t *, I:ydb_long_t, I:ydb_long_t *, I:ydb_ulong_t, I:ydb_ulong_t *, I:ydb_float_t, I:ydb_float_t *, I:ydb_double_t, I:ydb_double_t *, I:ydb_char_t *, I:ydb_string_t *)
ydbxc_test7: ydb_char_t* test7^testtypes(I:ydb_int_t, I:ydb_int_t *, I:ydb_uint_t, I:ydb_uint_t *, I:ydb_long_t, I:ydb_long_t *, I:ydb_ulong_t, I:ydb_ulong_t *, I:ydb_float_t, I:ydb_float_t *, I:ydb_double_t, I:ydb_double_t *, I:ydb_char_t *, I:ydb_string_t *)
ydbxc_test8: ydb_string_t* test8^testtypes(I:ydb_int_t, I:ydb_int_t *, I:ydb_uint_t, I:ydb_uint_t *, I:ydb_long_t, I:ydb_long_t *, I:ydb_ulong_t, I:ydb_ulong_t *, I:ydb_float_t, I:ydb_float_t *, I:ydb_double_t, I:ydb_double_t *, I:ydb_char_t *, I:ydb_string_t *)
ydbxc_test108: ydb_buffer_t* test108^testtypes(I:ydb_int_t, I:ydb_int_t *, I:ydb_uint_t, I:ydb_uint_t *, I:ydb_long_t, I:ydb_long_t *, I:ydb_ulong_t, I:ydb_ulong_t *, I:ydb_float_t, I:ydb_float_t *, I:ydb_double_t, I:ydb_double_t *, I:ydb_char_t *, I:ydb_buffer_t *)
ydbxc_test9: ydb_int_t* test9^testtypes(IO:ydb_int_t *, IO:ydb_uint_t *, IO:ydb_long_t *, IO:ydb_ulong_t *, IO:ydb_float_t *, IO:ydb_double_t *, IO:ydb_char_t *, IO:ydb_string_t *)
ydbxc_test10: ydb_uint_t* test10^testtypes(IO:ydb_int_t *, IO:ydb_uint_t *, IO:ydb_long_t *, IO:ydb_ulong_t *, IO:ydb_float_t *, IO:ydb_double_t *, IO:ydb_char_t *, IO:ydb_string_t *)
ydbxc_test11: ydb_long_t* test11^testtypes(IO:ydb_int_t *, IO:ydb_uint_t *, IO:ydb_long_t *, IO:ydb_ulong_t *, IO:ydb_float_t *, IO:ydb_double_t *, IO:ydb_char_t *, IO:ydb_string_t *)
ydbxc_test12: ydb_ulong_t* test12^testtypes(IO:ydb_int_t *, IO:ydb_uint_t *, IO:ydb_long_t *, IO:ydb_ulong_t *, IO:ydb_float_t *, IO:ydb_double_t *, IO:ydb_char_t *, IO:ydb_string_t *)
ydbxc_test13: ydb_float_t* test13^testtypes(IO:ydb_int_t *, IO:ydb_uint_t *, IO:ydb_long_t *, IO:ydb_ulong_t *, IO:ydb_float_t *, IO:ydb_double_t *, IO:ydb_char_t *, IO:ydb_string_t *)
ydbxc_test14: ydb_double_t* test14^testtypes(IO:ydb_int_t *, IO:ydb_uint_t *, IO:ydb_long_t *, IO:ydb_ulong_t *, IO:ydb_float_t *, IO:ydb_double_t *, IO:ydb_char_t *, IO:ydb_string_t *)
ydbxc_test15: ydb_char_t* test15^testtypes(IO:ydb_int_t *, IO:ydb_uint_t *, IO:ydb_long_t *, IO:ydb_ulong_t *, IO:ydb_float_t *, IO:ydb_double_t *, IO:ydb_char_t *, IO:ydb_string_t *)
ydbxc_test16: ydb_string_t* test16^testtypes(IO:ydb_int_t *, IO:ydb_uint_t *, IO:ydb_long_t *, IO:ydb_ulong_t *, IO:ydb_float_t *, IO:ydb_double_t *, IO:ydb_char_t *, IO:ydb_string_t *)
ydbxc_test116: ydb_buffer_t* test116^testtypes(IO:ydb_int_t *, IO:ydb_uint_t *, IO:ydb_long_t *, IO:ydb_ulong_t *, IO:ydb_float_t *, IO:ydb_double_t *, IO:ydb_char_t *, IO:ydb_buffer_t *)
ydbxc_test17: ydb_int_t* test17^testtypes(O:ydb_int_t *, O:ydb_uint_t *, O:ydb_long_t *, O:ydb_ulong_t *, O:ydb_float_t *, O:ydb_double_t *, O:ydb_char_t *, O:ydb_string_t *)
ydbxc_test18: ydb_uint_t* test18^testtypes(O:ydb_int_t *, O:ydb_uint_t *, O:ydb_long_t *, O:ydb_ulong_t *, O:ydb_float_t *, O:ydb_double_t *, O:ydb_char_t *, O:ydb_string_t *)
ydbxc_test19: ydb_long_t* test19^testtypes(O:ydb_int_t *, O:ydb_uint_t *, O:ydb_long_t *, O:ydb_ulong_t *, O:ydb_float_t *, O:ydb_double_t *, O:ydb_char_t *, O:ydb_string_t *)
ydbxc_test20: ydb_ulong_t* test20^testtypes(O:ydb_int_t *, O:ydb_uint_t *, O:ydb_long_t *, O:ydb_ulong_t *, O:ydb_float_t *, O:ydb_double_t *, O:ydb_char_t *, O:ydb_string_t *)
ydbxc_test21: ydb_float_t* test21^testtypes(O:ydb_int_t *, O:ydb_uint_t *, O:ydb_long_t *, O:ydb_ulong_t *, O:ydb_float_t *, O:ydb_double_t *, O:ydb_char_t *, O:ydb_string_t *)
ydbxc_test22: ydb_double_t* test22^testtypes(O:ydb_int_t *, O:ydb_uint_t *, O:ydb_long_t *, O:ydb_ulong_t *, O:ydb_float_t *, O:ydb_double_t *, O:ydb_char_t *, O:ydb_string_t *)
ydbxc_test23: ydb_char_t* test23^testtypes(O:ydb_int_t *, O:ydb_uint_t *, O:ydb_long_t *, O:ydb_ulong_t *, O:ydb_float_t *, O:ydb_double_t *, O:ydb_char_t *, O:ydb_string_t *)
ydbxc_test24: ydb_string_t* test24^testtypes(O:ydb_int_t *, O:ydb_uint_t *, O:ydb_long_t *, O:ydb_ulong_t *, O:ydb_float_t *, O:ydb_double_t *, O:ydb_char_t *, O:ydb_string_t *)
ydbxc_test124: ydb_buffer_t* test124^testtypes(O:ydb_int_t *, O:ydb_uint_t *, O:ydb_long_t *, O:ydb_ulong_t *, O:ydb_float_t *, O:ydb_double_t *, O:ydb_char_t *, O:ydb_buffer_t *)
args1tab
ydbxc_test_types


echo "### Restart the tests but now for standard C types"
setenv GTMCI args1b.tab
cat >> $GTMCI << args1tab
ydbxc_test0: void test0^testtypes()
ydbxc_test1: int* test1^testtypes(I:int, I:int *, I:uint, I:uint *, I:long, I:long *, I:ulong, I:ulong *, I:float, I:float *, I:double, I:double *, I:char *, I:string *)
ydbxc_test2: uint* test2^testtypes(I:int, I:int *, I:uint, I:uint *, I:long, I:long *, I:ulong, I:ulong *, I:float, I:float *, I:double, I:double *, I:char *, I:string *)
ydbxc_test3: long* test3^testtypes(I:int, I:int *, I:uint, I:uint *, I:long, I:long *, I:ulong, I:ulong *, I:float, I:float *, I:double, I:double *, I:char *, I:string *)
ydbxc_test4: ulong* test4^testtypes(I:int, I:int *, I:uint, I:uint *, I:long, I:long *, I:ulong, I:ulong *, I:float, I:float *, I:double, I:double *, I:char *, I:string *)
ydbxc_test5: float* test5^testtypes(I:int, I:int *, I:uint, I:uint *, I:long, I:long *, I:ulong, I:ulong *, I:float, I:float *, I:double, I:double *, I:char *, I:string *)
ydbxc_test6: double* test6^testtypes(I:int, I:int *, I:uint, I:uint *, I:long, I:long *, I:ulong, I:ulong *, I:float, I:float *, I:double, I:double *, I:char *, I:string *)
ydbxc_test7: char* test7^testtypes(I:int, I:int *, I:uint, I:uint *, I:long, I:long *, I:ulong, I:ulong *, I:float, I:float *, I:double, I:double *, I:char *, I:string *)
ydbxc_test8: string* test8^testtypes(I:int, I:int *, I:uint, I:uint *, I:long, I:long *, I:ulong, I:ulong *, I:float, I:float *, I:double, I:double *, I:char *, I:string *)
ydbxc_test108: ydb_buffer_t* test108^testtypes(I:int, I:int *, I:uint, I:uint *, I:long, I:long *, I:ulong, I:ulong *, I:float, I:float *, I:double, I:double *, I:char *, I:ydb_buffer_t *)
ydbxc_test9: int* test9^testtypes(IO:int *, IO:uint *, IO:long *, IO:ulong *, IO:float *, IO:double *, IO:char *, IO:string *)
ydbxc_test10: uint* test10^testtypes(IO:int *, IO:uint *, IO:long *, IO:ulong *, IO:float *, IO:double *, IO:char *, IO:string *)
ydbxc_test11: long* test11^testtypes(IO:int *, IO:uint *, IO:long *, IO:ulong *, IO:float *, IO:double *, IO:char *, IO:string *)
ydbxc_test12: ulong* test12^testtypes(IO:int *, IO:uint *, IO:long *, IO:ulong *, IO:float *, IO:double *, IO:char *, IO:string *)
ydbxc_test13: float* test13^testtypes(IO:int *, IO:uint *, IO:long *, IO:ulong *, IO:float *, IO:double *, IO:char *, IO:string *)
ydbxc_test14: double* test14^testtypes(IO:int *, IO:uint *, IO:long *, IO:ulong *, IO:float *, IO:double *, IO:char *, IO:string *)
ydbxc_test15: char* test15^testtypes(IO:int *, IO:uint *, IO:long *, IO:ulong *, IO:float *, IO:double *, IO:char *, IO:string *)
ydbxc_test16: string* test16^testtypes(IO:int *, IO:uint *, IO:long *, IO:ulong *, IO:float *, IO:double *, IO:char *, IO:string *)
ydbxc_test116: ydb_buffer_t* test116^testtypes(IO:int *, IO:uint *, IO:long *, IO:ulong *, IO:float *, IO:double *, IO:char *, IO:ydb_buffer_t *)
ydbxc_test17: int* test17^testtypes(O:int *, O:uint *, O:long *, O:ulong *, O:float *, O:double *, O:char *, O:string *)
ydbxc_test18: uint* test18^testtypes(O:int *, O:uint *, O:long *, O:ulong *, O:float *, O:double *, O:char *, O:string *)
ydbxc_test19: long* test19^testtypes(O:int *, O:uint *, O:long *, O:ulong *, O:float *, O:double *, O:char *, O:string *)
ydbxc_test20: ulong* test20^testtypes(O:int *, O:uint *, O:long *, O:ulong *, O:float *, O:double *, O:char *, O:string *)
ydbxc_test21: float* test21^testtypes(O:int *, O:uint *, O:long *, O:ulong *, O:float *, O:double *, O:char *, O:string *)
ydbxc_test22: double* test22^testtypes(O:int *, O:uint *, O:long *, O:ulong *, O:float *, O:double *, O:char *, O:string *)
ydbxc_test23: char* test23^testtypes(O:int *, O:uint *, O:long *, O:ulong *, O:float *, O:double *, O:char *, O:string *)
ydbxc_test24: string* test24^testtypes(O:int *, O:uint *, O:long *, O:ulong *, O:float *, O:double *, O:char *, O:string *)
ydbxc_test124: ydb_buffer_t * test124^testtypes(O:int*, O:uint*, O:long*, O:ulong*, O:float*, O:double*, O:char*, O:ydb_buffer_t*)
args1tab
ydbxc_test_types


echo "### Now test that various other types are treated as invalid"
echo "Detail results in ydbxc_test_types.invalid\n"

# List of types to test to make sure they are invalid when passed as parameters
set types = "char string buffer" # strings must be pointer types
# ydb_char_t** and ydb_status_t are not documented as valid for call-ins, so explicitly test that they are not accepted
set types = "$types ydb_char_tPP charPP ydb_status_t ydb_status_tP"
# ydb_pointertofunc_t(*) only applies to call-outs, not call-ins
set types = "$types ydb_pointertofunc_t ydb_pointertofunc_tP"
# call-ins do not support java types
set types = "$types ydb_jboolean ydb_jint ydb_jlong ydb_jfloat ydb_jdouble ydb_jstring ydb_jbyte_array ydb_jbig_decimal"

# Loop through types, testing that each is invalid as a parameter
echo >! ydbxc_test_types.invalid  # Clear test result artifact
foreach type ( $types )
    echo
    echo "Testing that type $type is invalid as input-only parameter"
    echo "Testing that type $type is invalid as input-only parameter" >> ydbxc_test_types.invalid
    setenv GTMCI "args2-$type-I.tab"
    echo >! "$GTMCI" "ydbxc_test0: void:as/P/*/ test0^testtypes(I:$type)"
    echo >! "$GTMCI" "ydbxc_test0: $type:as/P/*/ test0^testtypes()"
    ydbxc_test_types >& ydbxc_test_types.invalid.tmp
    cat ydbxc_test_types.invalid.tmp >> ydbxc_test_types.invalid  # Add to complete test result artifact
    cat ydbxc_test_types.invalid.tmp | grep -o "CIRTNTYP.*Invalid return type"

    echo "Testing that type $type is invalid as IO parameter"
    echo "Testing that type $type is invalid as IO parameter" >> ydbxc_test_types.invalid
    setenv GTMCI "args2-$type-IO.tab"
    echo >! "$GTMCI" "ydbxc_test0: void:as/P/*/ test0^testtypes(IO:$type)"
    echo >! "$GTMCI" "ydbxc_test0: $type:as/P/*/ test0^testtypes()"
    ydbxc_test_types >& ydbxc_test_types.invalid.tmp
    cat ydbxc_test_types.invalid.tmp >> ydbxc_test_types.invalid  # Add to complete test result artifact
    cat ydbxc_test_types.invalid.tmp | grep -o "CIRTNTYP.*Invalid return type"

    echo "Testing that type $type is invalid as output-only parameter"
    echo "Testing that type $type is invalid as output-only parameter" >> ydbxc_test_types.invalid
    setenv GTMCI "args2-$type-O.tab"
    echo >! "$GTMCI" "ydbxc_test0: void:as/P/*/ test0^testtypes(O:$type)"
    echo >! "$GTMCI" "ydbxc_test0: $type:as/P/*/ test0^testtypes()"
    ydbxc_test_types >& ydbxc_test_types.invalid.tmp
    cat ydbxc_test_types.invalid.tmp >> ydbxc_test_types.invalid  # Add to complete test result artifact
    cat ydbxc_test_types.invalid.tmp | grep -o "CIRTNTYP.*Invalid return type"
end

# Add more types to make sure they are invalid *return* types
# non-pointer types can't be returned with the call_in mechanism
set types = "$types int uint long ulong float double"
set types = "$types ydb_int_t ydb_uint_t ydb_long_t ydb_ulong_t ydb_float_t ydb_double_t ydb_char_t ydb_string_t ydb_buffer_t"

# Loop through types, testing that each is invalid as a retval
echo >! ydbxc_test_types.invalid  # Clear test result artifact
foreach type ( $types )
    echo
    echo "Testing that type $type is invalid as retval"
    echo "Testing that type $type is invalid as retval" >> ydbxc_test_types.invalid
    setenv GTMCI "args2-$type-retval.tab"
    echo >! "$GTMCI" "ydbxc_test0: $type:as/P/*/ test0^testtypes()"
    ydbxc_test_types >& ydbxc_test_types.invalid.tmp
    cat ydbxc_test_types.invalid.tmp >> ydbxc_test_types.invalid  # Add to complete test result artifact
    cat ydbxc_test_types.invalid.tmp | grep -o "CIRTNTYP.*Invalid return type"
end


unsetenv GTMCI
#$gtm_tst/com/dbcheck.csh -extract
