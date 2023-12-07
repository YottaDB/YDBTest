/****************************************************************
*
* Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
* All rights reserved.
*
* This source code contains the intellectual property
* of its copyright holder(s), and is made available
* under a license.  If you do not know the terms of
* the license, please stop and do not read further.
*
****************************************************************/
/* Test various return values from external call-outs
 * Note: basic.csh / make_fcn.csh already test the following retvals:
 *   void, gtm_long_t, gtm_ulong_t, gtm_status_t, gtm_int_t, gtm_uint_t
 */
#include <limits.h>
#include "gtm_stdio.h"
#include "gtmxc_types.h"


#define ASSERT(X) \
{ \
	if (!(X)) {	\
		PRINTF("ASSERT: ** Assert failed (%p) at line %d in file %s\n", #X, __LINE__, __FILE__); \
		fflush(stdout);	\
	} \
}

#define FUNC(ret_type, funcname, retval) \
	ret_type funcname() { \
		PRINTF(#funcname "() is returning: " #retval "\n"); \
		fflush(stdout); \
		return retval; \
	}

#define PTR_FUNC(ret_type, funcname, retval) \
	ret_type* funcname() { \
		ret_type* val = ydb_malloc(sizeof(ret_type)); \
		ASSERT(val); \
		*val = retval; \
		PRINTF(#funcname "() is returning: " #retval "\n"); \
		fflush(stdout); \
		return val; \
	}


/* Test standard types */

FUNC(void, ret_void,);
FUNC(ydb_status_t, ret_status_zero, 0);
FUNC(ydb_status_t, ret_status_negative, -1);
FUNC(ydb_status_t, ret_status_positive, 1);

FUNC(ydb_int_t, ret_int, 2147483647);
FUNC(ydb_uint_t, ret_uint, 4294967295U);
FUNC(ydb_long_t, ret_long, 2147483647);
FUNC(ydb_ulong_t, ret_ulong, 4294967295U);

/* 64-bit only section */
#if UINTPTR_MAX == 0xffffffffffffffff
FUNC(ydb_int64_t, ret_int64, -9223372036854775807LL); /* -2^63-1: use most negative int64 value */
FUNC(ydb_uint64_t, ret_uint64, 18446744073709551615ULL); /* 2^64-1: use largest uint64 value */
#endif

PTR_FUNC(ydb_int_t, ret_int_ptr, 2147483647);
PTR_FUNC(ydb_uint_t, ret_uint_ptr, 4294967295U);
PTR_FUNC(ydb_long_t, ret_long_ptr, 2147483647);
PTR_FUNC(ydb_ulong_t, ret_ulong_ptr, 4294967295U);
PTR_FUNC(ydb_int64_t, ret_int64_ptr, -9223372036854775807LL); /* -2^63-1: use most negative int64 value */
PTR_FUNC(ydb_uint64_t, ret_uint64_ptr, 18446744073709551615ULL); /* 2^64-1: use largest uint64 value */
PTR_FUNC(ydb_float_t, ret_float_ptr, 1234.567);
PTR_FUNC(ydb_double_t, ret_double_ptr, 1.79769313486232E+46); /* use nearly YDB's full 18-digit accuracy */


/* Skip all Java tests, in favour of the existing java test */
#if 0
/* Test java types are accepted (it is not clear that these should be accepted: they are not documented and do not work properly) */
FUNC(gtm_jboolean_t, gtm_xcjboolean, 1);
FUNC(gtm_jint_t, gtm_xcjint, 2147483647);
FUNC(gtm_jlong_t, gtm_xcjlong, 2147483647);
FUNC(gtm_jfloat_t, gtm_xcjfloat, 1234.567);
FUNC(gtm_jdouble_t, gtm_xcjdouble, 1.79769313486232E+46); /* use nearly YDB's full 18-digit accuracy */
FUNC(gtm_jstring_t, gtm_xcjstring, 'A');
FUNC(gtm_jbyte_array_t, gtm_xcjbyte_array, 'A');
FUNC(gtm_jbig_decimal_t, gtm_xcjbig_decimal, 'A');
#endif

/* Test all character types */

char *malloced_string(char *test_string) {
	ydb_char_t* string = ydb_malloc(strlen(test_string)+1);
	ASSERT(string);
	strcpy(string, test_string);
	return string;
}

ydb_char_t* ret_char_ptr() {
	ydb_char_t* string = malloced_string("TestString");
	PRINTF("ret_char_tptr() is returning: \"%s\"\n", string);
	fflush(stdout);
	return string;
}

ydb_char_t** ret_char_ptrptr() {
	ydb_char_t* string = malloced_string("TestString");
	ydb_char_t** val = ydb_malloc(sizeof(ydb_char_t*));
	ASSERT(val);
	*val = string;
	PRINTF("ret_char_tptrptr() is returning pointer to: \"%s\"\n", *val);
	fflush(stdout);
	return val;
}

ydb_string_t* ret_string_ptr() {
	ydb_char_t* string = malloced_string("TestString");
	ydb_string_t* val = ydb_malloc(sizeof(ydb_string_t));
	ASSERT(val);
	val->address = string;
	val->length = strlen(string);
	PRINTF("ret_string_tptr() is returning pointer to ydb_string_t containing: \"%s\"\n", val->address);
	fflush(stdout);
	return val;
}

ydb_buffer_t* ret_buffer_ptr() {
	ydb_char_t* string = malloced_string("TestString");
	ydb_buffer_t* val = ydb_malloc(sizeof(ydb_buffer_t));
	ASSERT(val);
	val->buf_addr = string;
	val->len_used = val->len_alloc = strlen(string);
	PRINTF("ret_buffer_tptr() is returning pointer to ydb_buffer_t containing: \"%s\"\n", val->buf_addr);
	fflush(stdout);
	return val;
}
