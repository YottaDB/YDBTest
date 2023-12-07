////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
// All rights reserved.
//
//	This source code contains the intellectual property
//	of its copyright holder(s), and is made available
//	under a license.  If you do not know the terms of
// the license, please stop and do not read further.
//
////////////////////////////////////////////////////////////////////////////////
retvals.so
void: void ret_void()
statusZero: ydb_status_t ret_status_zero()
statusNegative: ydb_status_t ret_status_negative()
statusPositive: ydb_status_t ret_status_positive()

int: int ret_int()
uint: uint ret_uint()
long: long ret_long()
ulong: ulong ret_ulong()
intPtr: int* ret_int_ptr()
uintPtr: uint* ret_uint_ptr()
longPtr: long* ret_long_ptr()
ulongPtr: ulong* ret_ulong_ptr()
floatPtr: float* ret_float_ptr()
doublePtr: double* ret_double_ptr()
charPtr: char* ret_char_ptr()
charPtrPtr: char** ret_char_ptrptr()
stringPtr: string* ret_string_ptr()

yint: ydb_int_t ret_int()
yuint: ydb_uint_t ret_uint()
ylong: ydb_long_t ret_long()
yulong: ydb_ulong_t ret_ulong()
yint64: ydb_int64_t ret_int64()
yuint64: ydb_uint64_t ret_uint64()

yintPtr: ydb_int_t* ret_int_ptr()
yuintPtr: ydb_uint_t* ret_uint_ptr()
ylongPtr: ydb_long_t* ret_long_ptr()
yulongPtr: ydb_ulong_t* ret_ulong_ptr()
yint64Ptr: ydb_int64_t* ret_int64_ptr()
yuint64Ptr: ydb_uint64_t* ret_uint64_ptr()
yfloatPtr: ydb_float_t* ret_float_ptr()
ydoublePtr: ydb_double_t* ret_double_ptr()

ycharPtr: ydb_char_t* ret_char_ptr()
ycharPtrPtr: ydb_char_t** ret_char_ptrptr()
ystringPtr: ydb_string_t* ret_string_ptr()
ybufferPtr: ydb_buffer_t* ret_buffer_ptr()


gstatusZero: ydb_status_t ret_status_zero()
gstatusNegative: ydb_status_t ret_status_negative()
gstatusPositive: ydb_status_t ret_status_positive()

gint: gtm_int_t ret_int()
guint: gtm_uint_t ret_uint()
glong: gtm_long_t ret_long()
gulong: gtm_ulong_t ret_ulong()

gintPtr: gtm_int_t* ret_int_ptr()
guintPtr: gtm_uint_t* ret_uint_ptr()
glongPtr: gtm_long_t* ret_long_ptr()
gulongPtr: gtm_ulong_t* ret_ulong_ptr()
gfloatPtr: gtm_float_t* ret_float_ptr()
gdoublePtr: gtm_double_t* ret_double_ptr()

gcharPtr: gtm_char_t* ret_char_ptr()
gcharPtrPtr: gtm_char_t** ret_char_ptrptr()
gstringPtr: gtm_string_t* ret_string_ptr()

//Skip all Java tests, in favour of the existing java test
//See thread at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/398#note_1698692806
//gjboolean: gtm_jboolean_t gtm_xcjboolean()
//gjint: gtm_jint_t gtm_xcjint()
//gjlong: gtm_jlong_t gtm_xcjlong()
//gjfloat: gtm_jfloat_t gtm_xcjfloat()
//gjdouble: gtm_jdouble_t gtm_xcjdouble()
//gjstring: gtm_jstring_t gtm_xcjstring()
//gjbyteArray: gtm_jbyte_array_t gtm_xcjbyte_array()
//gjbigDecimal: gtm_jbig_decimal_t gtm_xcjbig_decimal()
