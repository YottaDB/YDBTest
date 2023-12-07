/****************************************************************
 *
 * Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
 * All rights reserved.
 *
 *	This source code contains the intellectual property
 *	of its copyright holder(s), and is made available
 *	under a license.  If you do not know the terms of
 *	the license, please stop and do not read further.
 *
 ****************************************************************/
/* The following tests exercise call_ins to M from C routines using all the gtm types from
   libyottadb.h.  The initial test0() checks a void return and 0 args; then come arg tests.
   For the I: types pointer and non-pointer arguments are valid.  For the IO:
   and O: types only pointer arguments are valid.  The first 8+1 are I: tests where the C routine
   sends values for each of the variable arguments to M as both pointers and non-pointers for
   all valid types, but they are read-only to M.  In each case the arguments are the same but a
   different type of return argument from M is specified.  The +1 test after the first 8, re-uses
   test 8 as test 108, but for ydb_buffer_t rather than ydb_string_t.  The next 8+1 are IO: tests which accept
   only the pointer types to M. The M function will send back a different value for each of the
   passed arguments as well as a different type of return argument.
   The final 8+1 are O: tests where the input from C is irrelevant.  We set it locally in C prior to
   each call to M, however, to make sure M modifies the arguments properly and we print the new values
   for each argument as well as the return values.

  Note: related tests are in subtests xc_test_types and ydbxc_test_types.
  Additional testing of ydb_buffer_t is in test r136/ydb565.
*/
#include <string.h>
#include <limits.h>
#include "gtm_stdio.h"
#include "libyottadb.h"
#include "shrenv.h"

#define ASSERT(status) \
	fflush(stdout); \
	if (status) { \
		ydb_char_t _errmsg[500]; \
		ydb_zstatus(&_errmsg[0], 800); \
		PRINTF(" %s \n", _errmsg); \
		fflush(stdout); \
		exit(1); \
	}

#define CHECKER(retval, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) \
	PRINTF("Returned arg1: %d\n", arg1); \
	PRINTF("Returned arg2: %u\n", arg2); \
	PRINTF("Returned arg3: %ld\n", arg3); \
	PRINTF("Returned arg4: %lu\n", arg4); \
	PRINTF("Returned arg5: %.3f\n", arg5); \
	PRINTF("Returned arg6: %.3f\n", arg6); \
	PRINTF("Returned arg7: %s\n", arg7); \
	arg8.address[arg8.length] = '\0'; \
	buf108.buf_addr[buf108.len_used] = '\0'; \
	PRINTF("Returned arg8: %s\n\n", arg8.address); \
	fflush(stdout);

/* There are only 2 variants of initialized args so put them into macros */
/* The first variant is used for I[nput] tests and the second for IO and O[utput] tests */
#define INIT_ARGS_A() \
	init_args(2147483647, 4294967295U, 2147483647, 4294967295U, 1234.567, 1234567.891, "This is arg7", "This is arg8", \
		&arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8, &buf108);

#define INIT_ARGS_B() \
	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8", \
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8, &buf108);

void init_args(ydb_int_t in1, ydb_uint_t in2, ydb_long_t in3, ydb_ulong_t in4, ydb_float_t in5, ydb_double_t in6, ydb_char_t *in7,
	       ydb_char_t *in8, ydb_int_t *a1, ydb_uint_t *a2, ydb_long_t *a3, ydb_ulong_t *a4, ydb_float_t *a5, ydb_double_t *a6,
	       ydb_char_t *a7, ydb_char_t *inbuf, ydb_string_t *a8, ydb_buffer_t *a108);

int raft_of_tests(void)
{
	ydb_int_t retval1;
	ydb_uint_t retval2;
	ydb_long_t retval3;
	ydb_ulong_t retval4;
	ydb_float_t retval5;
	ydb_double_t retval6;
	ydb_char_t retval7[100];
	ydb_string_t retval8;
	ydb_buffer_t retval_buf;

	ydb_int_t arg1;
	ydb_uint_t arg2;
	ydb_long_t arg3;
	ydb_ulong_t arg4;
	ydb_float_t arg5;
	ydb_double_t arg6;
	ydb_char_t arg7[100];
	ydb_string_t arg8;
	ydb_buffer_t buf108;
	ydb_char_t buf0[100];
	ydb_char_t buf[100];

	ci_name_descriptor	ydb_test9;

	/* THIS IS THE BEGINNING OF THE I: tests */

	INIT_ARGS_A();
	PRINTF("*** Start the test for I: arguments. ***\n\n");
	PRINTF("ydbxc_test_types arguments passed to M: \narg1 ydb_int_t: %d\narg2 ydb_int_t *: %d\narg3 "
		"ydb_uint_t: %u\narg4 ydb_uint_t *: %u\narg5 ydb_long_t: %ld\narg6 ydb_long_t *: %ld\narg7 "
		"ydb_ulong_t: %lu\narg8 ydb_ulong_t *: %lu\narg9 ydb_float_t: %.3f\narg10 ydb_float_t *: %.3f\n"
		"arg11 ydb_double_t: %.3f\narg12 ydb_double_t *: %.3f\narg13 ydb_char_t: %s\narg14 ydb_string_t: %s"
		"\n\n",
		arg1, arg1, arg2, arg2, arg3, arg3, arg4, arg4, arg5, arg5, arg6, arg6, &arg7[0], arg8.address);

	/* test1 returns ydb_int_t * */
	ASSERT(ydb_ci("ydbxc_test1", &retval1, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %d\n\n", retval1);

	/* test2 returns ydb_uint_t * */
	ASSERT(ydb_ci("ydbxc_test2", &retval2, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %u\n\n", retval2);

	/* test3 returns ydb_long_t * */
	ASSERT(ydb_ci("ydbxc_test3", &retval3, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %ld\n\n", retval3);

	/* test4 returns ydb_long_t * */
	ASSERT(ydb_ci("ydbxc_test4", &retval4, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %lu\n\n", retval4);

	/* test5 returns ydb_float_t * */
	ASSERT(ydb_ci("ydbxc_test5", &retval5, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %.4f\n\n", retval5);

	/* test6 returns ydb_double_t * */
	ASSERT(ydb_ci("ydbxc_test6", &retval6, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %.4f\n\n", retval6);

	/* test7 returns ydb_char_t * */
	ASSERT(ydb_ci("ydbxc_test7", retval7, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %s\n\n", retval7);

	/* test8 returns ydb_string_t * */
	memset(buf, sizeof(buf), '!');  /* Fill it with something so that we notice if it's not being correctly set on return */
	retval8.address = buf;
	retval8.length = sizeof(buf)-1;	/* set max length before "ydb_ci" call; leave room for our terminator  later */
	ASSERT(ydb_ci("ydbxc_test8", &retval8, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	retval8.address[retval8.length] = '\0'; /* NUL-terminate so C can print it */
	PRINTF("Returned value: %s\n\n", retval8.address);

	/* re-do test8 as test108 but returning ydb_buffer_t* and also using buffer for arg8 */
	memset(buf, sizeof(buf), '!');  /* Fill it with something so that we notice if it's not being correctly set on return */
	retval_buf.buf_addr = buf;
	retval_buf.len_alloc = sizeof(buf)-1; /* set max length before "ydb_ci" call; leave room for our terminator  later */
	retval_buf.len_used = sizeof(buf)-1;  /* set length of input string -- ydb should ignore this */
	ASSERT(ydb_ci("ydbxc_test108", &retval_buf, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &buf108));
	retval_buf.buf_addr[retval_buf.len_used] = '\0';  /* NUL-terminate so C can print it */
	PRINTF("Returned value: %s\n\n", retval_buf.buf_addr);

	/* THIS IS THE BEGINNING OF THE IO: tests */

	PRINTF("*** Start the test for IO: arguments. ***\n\n");

	INIT_ARGS_B();
	PRINTF("ydbxc_test_types arguments passed to M: \narg1 ydb_int_t *: %d\narg2 ydb_uint_t *: %u\n"
		"arg3 ydb_long_t *: %ld\narg4 ydb_ulong_t *: %lu\narg5 ydb_float_t *: %.3f\narg6 ydb_double_t *: "
		"%.3f\narg7 ydb_char_t *: %s\narg8 ydb_string_t *: %s\n\n",
		arg1, arg2, arg3, arg4, arg5, arg6, &arg7[0], arg8.address);
	fflush(stdout);

	/* test9 returns ydb_int_t * specifically using ydb_cip() */
	ydb_test9.rtn_name.address = "ydbxc_test9";
	ydb_test9.rtn_name.length = strlen(ydb_test9.rtn_name.address);
	ydb_test9.handle = NULL;
	ASSERT(ydb_cip(&ydb_test9, &retval1, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %d\n\n", retval1);

	/* test10 returns ydb_uint_t * */
	INIT_ARGS_B();
	ASSERT(ydb_ci("ydbxc_test10", &retval2, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %u\n\n", retval2);

	/* test11 returns ydb_long_t * */
	INIT_ARGS_B();
	ASSERT(ydb_ci("ydbxc_test11", &retval3, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %ld\n\n", retval3);

	/* test12 returns ydb_ulong_t * */
	INIT_ARGS_B();
	ASSERT(ydb_ci("ydbxc_test12", &retval4, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %lu\n\n", retval4);

	/* test13 returns ydb_float_t * */
	INIT_ARGS_B();
	ASSERT(ydb_ci("ydbxc_test13", &retval5, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %.4f\n\n", retval5);

	/* test14 returns ydb_double_t * */
	INIT_ARGS_B();
	ASSERT(ydb_ci("ydbxc_test14", &retval6, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %.4f\n\n", retval6);

	/* test15 returns ydb_char_t * */
	INIT_ARGS_B();
	ASSERT(ydb_ci("ydbxc_test15", retval7, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %s\n\n", retval7);

	/* test16 returns ydb_string_t * */
	INIT_ARGS_B();
	memset(buf, sizeof(buf), '!');  /* Fill it with something so that we notice if it's not being correctly set on return */
	retval8.length = sizeof(buf)-1;	/* set max length before "ydb_ci" call; leave room for our terminator  later */
	ASSERT(ydb_ci("ydbxc_test16", &retval8, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	retval8.address[retval8.length] = '\0';  /* NUL-terminate so C can print it */
	PRINTF("Returned value: %s\n\n", retval8.address);

	/* re-do test16 as test116 but returning ydb_buffer_t* and also using buffer for arg8 */
	INIT_ARGS_B();
	memset(buf, sizeof(buf), '!');  /* Fill it with something so that we notice if it's not being correctly set on return */
	retval_buf.buf_addr = buf;
	retval_buf.len_alloc = sizeof(buf)-1; /* set max length before "ydb_ci" call; leave room for our terminator  later */
	retval_buf.len_used = sizeof(buf)-1;  /* set length of input string -- ydb should ignore this */
	ASSERT(ydb_ci("ydbxc_test116", &retval_buf, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &buf108));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	retval_buf.buf_addr[retval_buf.len_used] = '\0';  /* NUL-terminate so C can print it */
	PRINTF("Returned value: %s\n\n", retval_buf.buf_addr);

	/* THIS IS THE BEGINNING OF THE O: tests */

	PRINTF("*** Start the test for O: arguments. ***\n\n");

	INIT_ARGS_B();
	PRINTF("ydbxc_test_types arguments passed to M: \narg1 ydb_int_t *: %d\narg2 ydb_uint_t "
			      "*: %u\narg3 ydb_long_t *: %ld\narg4 ydb_ulong_t *: %lu\narg5 ydb_float_t *: %.3f"
			      "\narg6 ydb_double_t *: %.3f\narg7 ydb_char_t *: %s\narg8 ydb_string_t *: %s\n\n",
			      arg1, arg2, arg3, arg4, arg5, arg6, &arg7[0], arg8.address);
	fflush(stdout);

	/* test17 returns ydb_int_t * */
	ASSERT(ydb_ci("ydbxc_test17", &retval1, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %d\n\n", retval1);

	/* test18 returns ydb_uint_t * */
	INIT_ARGS_B();
	ASSERT(ydb_ci("ydbxc_test18", &retval2, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %u\n\n", retval2);

	/* test19 returns ydb_long_t * */
	INIT_ARGS_B();
	ASSERT(ydb_ci("ydbxc_test19", &retval3, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %ld\n\n", retval3);

	/* test20 returns ydb_ulong_t * */
	INIT_ARGS_B();
	ASSERT(ydb_ci("ydbxc_test20", &retval4, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %lu\n\n", retval4);

	/* test21 returns ydb_float_t * */
	INIT_ARGS_B();
	ASSERT(ydb_ci("ydbxc_test21", &retval5, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %.3f\n\n", retval5);

	/* test22 returns ydb_double_t * */
	INIT_ARGS_B();
	ASSERT(ydb_ci("ydbxc_test22", &retval6, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %.3f\n\n", retval6);

	/* test23 returns ydb_char_t * */
	INIT_ARGS_B();
	ASSERT(ydb_ci("ydbxc_test23", retval7, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %s\n\n", retval7);

	/* test24 returns ydb_string_t * */
	INIT_ARGS_B();
	memset(buf, sizeof(buf), '!');  /* Fill it with something so that we notice if it's not being correctly set on return */
	retval8.length = sizeof(buf)-1;	/* set max length before "ydb_ci" call; leave room for our terminator  later */
	ASSERT(ydb_ci("ydbxc_test24", &retval8, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8))
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	retval8.address[retval8.length] = '\0';
	PRINTF("Returned value: %s\n\n", retval8.address);

	/* re-do test24 as test124 but returning ydb_buffer_t* and also using buffer for arg8 */
	INIT_ARGS_B();
	memset(buf, sizeof(buf), '!');  /* Fill it with something so that we notice if it's not being correctly set on return */
	retval_buf.buf_addr = buf;
	retval_buf.len_alloc = sizeof(buf)-1; /* set max length before "ydb_ci" call; leave room for our terminator  later */
	retval_buf.len_used = sizeof(buf)-1;  /* set length of input string -- ydb should ignore this */
	ASSERT(ydb_ci("ydbxc_test124", &retval_buf, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &buf108));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	retval_buf.buf_addr[retval_buf.len_used] = '\0';  /* NUL-terminate so C can print it */
	PRINTF("Returned value: %s\n\n", retval_buf.buf_addr);
}

/* This routine initializes all the arguments passed to M */

void init_args(ydb_int_t in1, ydb_uint_t in2, ydb_long_t in3, ydb_ulong_t in4, ydb_float_t in5, ydb_double_t in6,
	       ydb_char_t *in7, ydb_char_t *in8, ydb_int_t *a1, ydb_uint_t *a2, ydb_long_t *a3, ydb_ulong_t *a4,
	       ydb_float_t *a5, ydb_double_t *a6, ydb_char_t *a7, ydb_char_t *inbuf, ydb_string_t *a8, ydb_buffer_t *a108)
{
	fflush(stdout);
	*a1 = in1;
	*a2 = in2;
	*a3 = in3;
	*a4 = in4;
	*a5 = in5;
	*a6 = in6;
	strcpy(a7, in7);
	strcpy(inbuf, in8);
	a8->length = strlen(in8);
	a8->address = inbuf;
	a108->len_alloc = strlen(in8);
	a108->len_used = strlen(in8);
	a108->buf_addr = inbuf;
}


int main(void)
{
	ASSERT(ydb_init());
	PRINTF("\nYottaDB env. successfully initialized\n\n");
	fflush(stdout);

	/* TESTS VOID RETURN */
	/* test0 returns void */
	ASSERT(ydb_ci("ydbxc_test0"));
	/* test normally segfaults here if routine is not void and thus incorrectly tries to update a retval */
	PRINTF("Void routine correctly returned nothing\n\n");
	PRINTF("*** Tested VOID return ***\n\n");

	raft_of_tests();

	ASSERT(ydb_exit());
	PRINTF("\nYottaDB env. successfully shutdown\n\n");
	fflush(stdout);
	return 0;
}
