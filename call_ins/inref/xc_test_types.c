/****************************************************************
 *								*
 * Copyright (c) 2007-2014 Fidelity National Information	*
 * Services, Inc. and/or its subsidiaries. All rights reserved.	*
 *								*
 * Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
/* Refer to the comment at the top of ydbxc_test_types.c to describe the sequence of tests below.
  Note: related tests are in subtests xc_test_types and ydbxc_test_types.
*/
#include <string.h>
#include <limits.h>
#include "gtm_stdio.h"
#include "gtmxc_types.h"
#include "shrenv.h"

#define ASSERT(status) \
	fflush(stdout); \
	if (status) { \
		xc_char_t _errmsg[500]; \
		gtm_zstatus(&_errmsg[0], 800); \
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
	PRINTF("Returned arg8: %s\n\n", arg8.address); \
	fflush(stdout);

/* There are only 2 variants of initialized args so put them into macros */
/* The first variant is used for I[nput] tests and the second for IO and O[utput] tests */
#define INIT_ARGS_A() \
	init_args(2147483647, 4294967295U, 2147483647, 4294967295U, 1234.567, 1234567.891, "This is arg7", "This is arg8", \
		&arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

#define INIT_ARGS_B() \
	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8", \
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

void init_args(xc_int_t in1, xc_uint_t in2, xc_long_t in3, xc_ulong_t in4, xc_float_t in5, xc_double_t in6, xc_char_t *in7,
	       xc_char_t *in8, xc_int_t *a1, xc_uint_t *a2, xc_long_t *a3, xc_ulong_t *a4, xc_float_t *a5, xc_double_t *a6,
	       xc_char_t *a7, xc_char_t *inbuf, xc_string_t *a8);

int main()
{
	xc_int_t retval1;
	xc_uint_t retval2;
	xc_long_t retval3;
	xc_ulong_t retval4;
	xc_float_t retval5;
	xc_double_t retval6;
	xc_char_t retval7[100];
	xc_string_t retval8;
	xc_int_t arg1;
	xc_uint_t arg2;
	xc_long_t arg3;
	xc_ulong_t arg4;
	xc_float_t arg5;
	xc_double_t arg6;
	xc_char_t arg7[100];
	xc_string_t arg8;
	xc_char_t buf0[100];
	xc_char_t buf[100];

	ci_name_descriptor	ydb_test9;

	ASSERT(gtm_init());
	PRINTF("\nGTM env. successfully initialized\n\n");
	fflush(stdout);


	/* THIS IS THE BEGINNING OF THE I: tests */

	INIT_ARGS_A();
	PRINTF("*** Start the test for I: arguments. ***\n\n");
	PRINTF("xc_test_types arguments passed to M: \narg1 xc_int_t: %d\narg2 xc_int_t *: %d\narg3 "
		"xc_uint_t: %u\narg4 xc_uint_t *: %u\narg5 xc_long_t: %ld\narg6 xc_long_t *: %ld\narg7 "
		"xc_ulong_t: %lu\narg8 xc_ulong_t *: %lu\narg9 xc_float_t: %.3f\narg10 xc_float_t *: %.3f\n"
		"arg11 xc_double_t: %.3f\narg12 xc_double_t *: %.3f\narg13 xc_char_t: %s\narg14 xc_string_t: %s"
		"\n\n",
		arg1, arg1, arg2, arg2, arg3, arg3, arg4, arg4, arg5, arg5, arg6, arg6, &arg7[0], arg8.address);

	/* test1 returns xc_int_t * */
	ASSERT(gtm_ci("xc_test1", &retval1, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %d\n\n", retval1);

	/* test2 returns xc_uint_t * */
	ASSERT(gtm_ci("xc_test2", &retval2, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %u\n\n", retval2);

	/* test3 returns xc_long_t * */
	ASSERT(gtm_ci("xc_test3", &retval3, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %ld\n\n", retval3);

	/* test4 returns xc_ulong_t * */
	ASSERT(gtm_ci("xc_test4", &retval4, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %lu\n\n", retval4);

	/* test5 returns xc_float_t * */
	ASSERT(gtm_ci("xc_test5", &retval5, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %.4f\n\n", retval5);

	/* test6 returns xc_double_t * */
	ASSERT(gtm_ci("xc_test6", &retval6, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %.4f\n\n", retval6);

	/* test7 returns xc_char_t * */
	ASSERT(gtm_ci("xc_test7", retval7, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	PRINTF("Returned value: %s\n\n", retval7);

	/* test8 returns xc_string_t * */
	memset(buf, sizeof(buf), '!');  /* Fill it with something so that we notice if it's not being correctly set on return */
	retval8.address = buf;
	retval8.length = sizeof(buf)-1;	/* set max length before "xc_ci" call; leave room for our terminator  later */
	ASSERT(gtm_ci("xc_test8", &retval8, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6, arg7, &arg8));
	retval8.address[retval8.length] = '\0'; /* NUL-terminate so C can print it */
	PRINTF("Returned value: %s\n\n", retval8.address);

	/* THIS IS THE BEGINNING OF THE IO: tests */

	PRINTF("*** Start the test for IO: arguments. ***\n\n");

	INIT_ARGS_B();
	PRINTF("xc_test_types arguments passed to M: \narg1 xc_int_t *: %d\narg2 xc_uint_t *: %u\n"
		"arg3 xc_long_t *: %ld\narg4 xc_ulong_t *: %lu\narg5 xc_float_t *: %.3f\narg6 xc_double_t *: "
		"%.3f\narg7 xc_char_t *: %s\narg8 xc_string_t *: %s\n\n",
		arg1, arg2, arg3, arg4, arg5, arg6, &arg7[0], arg8.address);
	fflush(stdout);

	/* test9 returns xc_int_t * */
	ydb_test9.rtn_name.address = "xc_test9";
	ydb_test9.rtn_name.length = sizeof("xc_test9") - 1;
	ydb_test9.handle = NULL;
	ASSERT(gtm_cip(&ydb_test9, &retval1, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %d\n\n", retval1);

	/* test10 returns xc_uint_t * */
	INIT_ARGS_B();
	ASSERT(gtm_ci("xc_test10", &retval2, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %u\n\n", retval2);

	/* test11 returns xc_long_t * */
	INIT_ARGS_B();
	ASSERT(gtm_ci("xc_test11", &retval3, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %ld\n\n", retval3);

	/* test12 returns xc_ulong_t * */
	INIT_ARGS_B();
	ASSERT(gtm_ci("xc_test12", &retval4, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %lu\n\n", retval4);

	/* test13 returns xc_float_t * */
	INIT_ARGS_B();
	ASSERT(gtm_ci("xc_test13", &retval5, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %.4f\n\n", retval5);

	/* test14 returns xc_double_t * */
	INIT_ARGS_B();
	ASSERT(gtm_ci("xc_test14", &retval6, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %.4f\n\n", retval6);

	/* test15 returns xc_char_t * */
	INIT_ARGS_B();
	ASSERT(gtm_ci("xc_test15", retval7, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %s\n\n", retval7);

	/* test16 returns xc_string_t * */
	INIT_ARGS_B();
	memset(buf, sizeof(buf), '!');  /* Fill it with something so that we notice if it's not being correctly set on return */
	retval8.length = sizeof(buf)-1;	/* set max length before "xc_ci" call; leave room for our terminator  later */
	ASSERT(gtm_ci("xc_test16", &retval8, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	retval8.address[retval8.length] = '\0';  /* NUL-terminate so C can print it */
	PRINTF("Returned value: %s\n\n", retval8.address);

	/* THIS IS THE BEGINNING OF THE O: tests */

	PRINTF("*** Start the test for O: arguments. ***\n\n");

	INIT_ARGS_B();
	PRINTF("xc_test_types arguments passed to M: \narg1 xc_int_t *: %d\narg2 xc_uint_t "
			      "*: %u\narg3 xc_long_t *: %ld\narg4 xc_ulong_t *: %lu\narg5 xc_float_t *: %.3f"
			      "\narg6 xc_double_t *: %.3f\narg7 xc_char_t *: %s\narg8 xc_string_t *: %s\n\n",
			      arg1, arg2, arg3, arg4, arg5, arg6, &arg7[0], arg8.address);
	fflush(stdout);

	/* test17 returns xc_int_t * */
	ASSERT(gtm_ci("xc_test17", &retval1, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %d\n\n", retval1);

	/* test18 returns xc_uint_t * */
	INIT_ARGS_B();
	ASSERT(gtm_ci("xc_test18", &retval2, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %u\n\n", retval2);

	/* test19 returns xc_long_t * */
	INIT_ARGS_B();
	ASSERT(gtm_ci("xc_test19", &retval3, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %ld\n\n", retval3);

	/* test20 returns xc_ulong_t * */
	INIT_ARGS_B();
	ASSERT(gtm_ci("xc_test20", &retval4, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %lu\n\n", retval4);

	/* test21 returns xc_float_t * */
	INIT_ARGS_B();
	ASSERT(gtm_ci("xc_test21", &retval5, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %.3f\n\n", retval5);

	/* test22 returns xc_double_t * */
	INIT_ARGS_B();
	ASSERT(gtm_ci("xc_test22", &retval6, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %.3f\n\n", retval6);

	/* test23 returns xc_char_t * */
	INIT_ARGS_B();
	ASSERT(gtm_ci("xc_test23", retval7, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8));
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	PRINTF("Returned value: %s\n\n", retval7);

	/* test24 returns xc_string_t * */
	INIT_ARGS_B();
	memset(buf, sizeof(buf), '!');  /* Fill it with something so that we notice if it's not being correctly set on return */
	retval8.length = sizeof(buf)-1;	/* set max length before "xc_ci" call; leave room for our terminator  later */
	ASSERT(gtm_ci("xc_test24", &retval8, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8))
	CHECKER(&retval1, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	retval8.address[retval8.length] = '\0';
	PRINTF("Returned value: %s\n\n", retval8.address);


	ASSERT(gtm_exit());

	PRINTF("\nGTM env. successfully shutdown\n\n");
	fflush(stdout);
	return 0;
}



/* This routine initializes all the arguments passed to M */

void init_args(xc_int_t in1, xc_uint_t in2, xc_long_t in3, xc_ulong_t in4, xc_float_t in5, xc_double_t in6,
	       xc_char_t *in7, xc_char_t *in8, xc_int_t *a1, xc_uint_t *a2, xc_long_t *a3, xc_ulong_t *a4,
	       xc_float_t *a5, xc_double_t *a6, xc_char_t *a7, xc_char_t *inbuf, xc_string_t *a8)
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
}
