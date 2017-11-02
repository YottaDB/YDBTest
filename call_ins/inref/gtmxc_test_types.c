/****************************************************************
 *								*
 * Copyright (c) 2007-2014 Fidelity National Information	*
 * Services, Inc. and/or its subsidiaries. All rights reserved.	*
 *								*
 * Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
/* The following tests exercise call_ins to M from C routines using all the gtm types from
   gtmxc_types.h.  For the I: types pointer and non-pointer arguments are valid.  For the IO:
   and O: types only pointer arguments are valid.  The first 8 are I: tests where the C routine
   sends values for each of the variable arguments to M as both pointers and non-pointers for
   all valid types, but they are read only to M.  In each case the arguments are the same but a
   different type of return argument from M is specified.  The next 8 are IO: tests which accepts
   only the pointer types to M. The M function will send back a different value for each of the
   passed arguments as well as a different type of return argument.
   The final 8 are O: tests where the input from C is irrelevant.  We set it locally in C prior to
   each call to M, however, to make sure M modifies the arguments properly and we print the new values
   for each argument as well as the return values.
*/
#include <string.h>
#include <limits.h>
#include "gtm_stdio.h"
#include "gtmxc_types.h"
#include "shrenv.h"


void init_args(gtm_int_t in1, gtm_uint_t in2, gtm_long_t in3, gtm_ulong_t in4, gtm_float_t in5, gtm_double_t in6, gtm_char_t *in7,
	       gtm_char_t *in8, gtm_int_t *a1, gtm_uint_t *a2, gtm_long_t *a3, gtm_ulong_t *a4, gtm_float_t *a5, gtm_double_t *a6,
	       gtm_char_t *a7, gtm_char_t *inbuf, gtm_string_t *a8);

int main()
{
	int ext, init;
	gtm_char_t errmsg[500];
	gtm_status_t status;
	gtm_int_t retval1;
	gtm_uint_t retval2;
	gtm_long_t retval3;
	gtm_ulong_t retval4;
	gtm_float_t retval5;
	gtm_double_t retval6;
	gtm_char_t retval7[100];
	gtm_string_t retval8;
	gtm_int_t arg1;
	gtm_uint_t arg2;
	gtm_long_t arg3;
	gtm_ulong_t arg4;
	gtm_float_t arg5;
	gtm_double_t arg6;
	gtm_char_t arg7[100];
	gtm_string_t arg8;
	gtm_char_t buf0[100];
	gtm_char_t buf[100];
	ci_name_descriptor	ydb_test9;

	fflush(stdout);
	retval8.address = buf;
	init = gtm_init();
	if (0 != init)
	{
		fflush(stdout);
		gtm_zstatus(&errmsg[0], 500);
		PRINTF("%s \n", errmsg);
		fflush(stdout);
	} else
	{
		PRINTF("\nGTM env. successfully initialized\n\n");
		fflush(stdout);
	}

	/* THIS IS THE BEGINNING OF THE I: tests */

	init_args(2147483647, 4294967295U, 2147483647, 4294967295U, 1234.567, 1234567.891, "This is arg7", "This is arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);
	PRINTF("*** Start the test for I: arguments. ***\n\n");
#if defined(__osf__)
		PRINTF("gtmxc_test_types arguments passed to M: \narg1 gtm_int_t: %d\narg2 gtm_int_t *: %d\narg3 "
	       "gtm_uint_t: %u\narg4 gtm_uint_t *: %u\narg5 gtm_long_t: %d\narg6 gtm_long_t *: %d\narg7 "
	       "gtm_ulong_t: %u\narg8 gtm_ulong_t *: %u\narg9 gtm_float_t: %.3f\narg10 gtm_float_t *: %.3f\n"
	       "arg11 gtm_double_t: %.3f\narg12 gtm_double_t *: %.3f\narg13 gtm_char_t: %s\narg14 gtm_string_t: %s"
	       "\n\n",
	       arg1, arg1, arg2, arg2, arg3, arg3, arg4, arg4, arg5, arg5, arg6, arg6, &arg7[0], arg8.address);
#else
	PRINTF("gtmxc_test_types arguments passed to M: \narg1 gtm_int_t: %d\narg2 gtm_int_t *: %d\narg3 "
	       "gtm_uint_t: %u\narg4 gtm_uint_t *: %u\narg5 gtm_long_t: %ld\narg6 gtm_long_t *: %ld\narg7 "
	       "gtm_ulong_t: %lu\narg8 gtm_ulong_t *: %lu\narg9 gtm_float_t: %.3f\narg10 gtm_float_t *: %.3f\n"
	       "arg11 gtm_double_t: %.3f\narg12 gtm_double_t *: %.3f\narg13 gtm_char_t: %s\narg14 gtm_string_t: %s"
	       "\n\n",
	       arg1, arg1, arg2, arg2, arg3, arg3, arg4, arg4, arg5, arg5, arg6, arg6, &arg7[0], arg8.address);
#endif
	fflush(stdout);

	/* test1 returns gtm_int_t * */
	status = gtm_ci("gtmxc_test1", &retval1, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6,
			arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned value: %d\n\n", retval1);
	fflush(stdout);

	/* test2 returns gtm_uint_t * */
	status = gtm_ci("gtmxc_test2", &retval2, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6,
			arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned value: %u\n\n", retval2);
	fflush(stdout);

	/* test3 returns gtm_long_t * */
	status = gtm_ci("gtmxc_test3", &retval3, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6,
			arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}
#if defined(__osf__)
	PRINTF("Returned value: %d\n\n", retval3);
#else
	PRINTF("Returned value: %ld\n\n", retval3);
#endif
	fflush(stdout);

	/* test4 returns gtm_ulong_t * */
	status = gtm_ci("gtmxc_test4", &retval4, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6,
			arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}
#if defined(__osf__)
	PRINTF("Returned value: %u\n\n", retval4);
#else
	PRINTF("Returned value: %lu\n\n", retval4);
#endif
	fflush(stdout);

	/* test5 returns gtm_float_t * */
	status = gtm_ci("gtmxc_test5", &retval5, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6,
			arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned value: %.4f\n\n", retval5);
	fflush(stdout);

	/* test6 returns gtm_double_t * */
	status = gtm_ci("gtmxc_test6", &retval6, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6,
			arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned value: %.4f\n\n", retval6);
	fflush(stdout);

	/* test7 returns gtm_char_t * */
	status = gtm_ci("gtmxc_test7", retval7, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6,
			arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned value: %s\n\n", retval7);
	fflush(stdout);

	/* test8 returns gtm_string_t * */
	status = gtm_ci("gtmxc_test8", &retval8, arg1, &arg1, arg2, &arg2, arg3, &arg3, arg4, &arg4, arg5, &arg5, arg6, &arg6,
			arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	*(retval8.address + retval8.length) = '\0';

	PRINTF("Returned value: %s\n\n", retval8.address);
	fflush(stdout);

	/* THIS IS THE BEGINNING OF THE IO: tests */

	PRINTF("*** Start the test for IO: arguments. ***\n\n");

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);
#if defined(__osf__)
        PRINTF("gtmxc_test_types arguments passed to M: \narg1 gtm_int_t *: %d\narg2 gtm_uint_t *: %u\n"
			      "arg3 gtm_long_t *: %d\narg4 gtm_ulong_t *: %u\narg5 gtm_float_t *: %.3f\narg6 gtm_double_t *: "
			      "%.3f\narg7 gtm_char_t *: %s\narg8 gtm_string_t *: %s\n\n",
			      arg1, arg2, arg3, arg4, arg5, arg6, &arg7[0], arg8.address);
#else
        PRINTF("gtmxc_test_types arguments passed to M: \narg1 gtm_int_t *: %d\narg2 gtm_uint_t *: %u\n"
			      "arg3 gtm_long_t *: %ld\narg4 gtm_ulong_t *: %lu\narg5 gtm_float_t *: %.3f\narg6 gtm_double_t *: "
			      "%.3f\narg7 gtm_char_t *: %s\narg8 gtm_string_t *: %s\n\n",
			      arg1, arg2, arg3, arg4, arg5, arg6, &arg7[0], arg8.address);
#endif
	fflush(stdout);

	/* test9 returns gtm_int_t * */
	ydb_test9.rtn_name.address = "gtmxc_test9";
	ydb_test9.rtn_name.length = sizeof("gtmxc_test9") - 1;
	ydb_test9.handle = NULL;
	status = gtm_cip(&ydb_test9, &retval1, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
	PRINTF("Returned value: %d\n\n", retval1);
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test10 returns gtm_uint_t * */
	status = gtm_ci("gtmxc_test10", &retval2, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
	PRINTF("Returned value: %u\n\n", retval2);
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test11 returns gtm_long_t * */
	status = gtm_ci("gtmxc_test11", &retval3, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
#if defined(__osf__)
	PRINTF("Returned value: %d\n\n", retval3);
#else
	PRINTF("Returned value: %ld\n\n", retval3);
#endif
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test12 returns gtm_ulong_t * */
	status = gtm_ci("gtmxc_test12", &retval4, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
#if defined(__osf__)
	PRINTF("Returned value: %u\n\n", retval4);
#else
	PRINTF("Returned value: %lu\n\n", retval4);
#endif
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test13 returns gtm_float_t * */
	status = gtm_ci("gtmxc_test13", &retval5, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
	PRINTF("Returned value: %.4f\n\n", retval5);
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test14 returns gtm_double_t * */
	status = gtm_ci("gtmxc_test14", &retval6, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
	PRINTF("Returned value: %.4f\n\n", retval6);
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test15 returns gtm_char_t * */
	status = gtm_ci("gtmxc_test15", retval7, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
	PRINTF("Returned value: %s\n\n", retval7);
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test16 returns gtm_string_t * */
	status = gtm_ci("gtmxc_test16", &retval8, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	*(retval8.address + retval8.length) = '\0';

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
	PRINTF("Returned value: %s\n\n", retval8.address);
	fflush(stdout);

	/* THIS IS THE BEGINNING OF THE O: tests */

	PRINTF("*** Start the test for O: arguments. ***\n\n");
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);
#if defined(__osf__)
	PRINTF("gtmxc_test_types arguments passed to M: \narg1 gtm_int_t *: %d\narg2 gtm_uint_t "
			      "*: %u\narg3 gtm_long_t *: %d\narg4 gtm_ulong_t *: %u\narg5 gtm_float_t *: %.3f"
			      "\narg6 gtm_double_t *: %.3f\narg7 gtm_char_t *: %s\narg8 gtm_string_t *: %s\n\n",
			      arg1, arg2, arg3, arg4, arg5, arg6, &arg7[0], arg8.address);
#else
	PRINTF("gtmxc_test_types arguments passed to M: \narg1 gtm_int_t *: %d\narg2 gtm_uint_t "
			      "*: %u\narg3 gtm_long_t *: %ld\narg4 gtm_ulong_t *: %lu\narg5 gtm_float_t *: %.3f"
			      "\narg6 gtm_double_t *: %.3f\narg7 gtm_char_t *: %s\narg8 gtm_string_t *: %s\n\n",
			      arg1, arg2, arg3, arg4, arg5, arg6, &arg7[0], arg8.address);
#endif
	fflush(stdout);

	/* test17 returns gtm_int_t * */
	status = gtm_ci("gtmxc_test17", &retval1, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
	PRINTF("Returned value: %d\n\n", retval1);
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test18 returns gtm_uint_t * */
	status = gtm_ci("gtmxc_test18", &retval2, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
	PRINTF("Returned value: %u\n\n", retval2);
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test19 returns gtm_long_t * */
	status = gtm_ci("gtmxc_test19", &retval3, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
#if defined(__osf__)
	PRINTF("Returned value: %d\n\n", retval3);
#else
	PRINTF("Returned value: %ld\n\n", retval3);
#endif
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test20 returns gtm_ulong_t * */
	status = gtm_ci("gtmxc_test20", &retval4, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
#if defined(__osf__)
	PRINTF("Returned value: %u\n\n", retval4);
#else
	PRINTF("Returned value: %lu\n\n", retval4);
#endif
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test21 returns gtm_float_t * */
	status = gtm_ci("gtmxc_test21", &retval5, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
	PRINTF("Returned value: %.3f\n\n", retval5);
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test22 returns gtm_double_t * */
	status = gtm_ci("gtmxc_test22", &retval6, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
	PRINTF("Returned value: %.3f\n\n", retval6);
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test23 returns gtm_char_t * */
	status = gtm_ci("gtmxc_test23", retval7, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);
	fflush(stdout);
	PRINTF("Returned value: %s\n\n", retval7);
	fflush(stdout);

	init_args(2147483647, 1U, 2147483647, 1U, 34.567, 34567.891, "C version arg7", "C version arg8",
		  &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, buf0, &arg8);

	/* test24 returns gtm_string_t * */
	status = gtm_ci("gtmxc_test24", &retval8, &arg1, &arg2, &arg3, &arg4, &arg5, &arg6, arg7, &arg8);
	if (status)
	{
		gtm_zstatus(&errmsg[0], 800);
		PRINTF(" %s \n", errmsg);
	}

	PRINTF("Returned arg1: %d\n", arg1);
	PRINTF("Returned arg2: %u\n", arg2);
#if defined(__osf__)
	PRINTF("Returned arg3: %d\n", arg3);
	PRINTF("Returned arg4: %u\n", arg4);
#else
	PRINTF("Returned arg3: %ld\n", arg3);
	PRINTF("Returned arg4: %lu\n", arg4);
#endif
	PRINTF("Returned arg5: %.3f\n", arg5);
	PRINTF("Returned arg6: %.3f\n", arg6);
	PRINTF("Returned arg7: %s\n", arg7);
	*(arg8.address + arg8.length) = '\0';
	PRINTF("Returned arg8: %s\n\n", arg8.address);

	*(retval8.address + retval8.length) = '\0';

	PRINTF("Returned value: %s\n\n", retval8.address);
	fflush(stdout);

	ext = gtm_exit();
	if (0 != ext)
	{
		fflush(stdout);
		gtm_zstatus(&errmsg[0], 500);
		PRINTF("%s \n", errmsg);
		fflush(stdout);
	} else
	{
		PRINTF("\nGTM env. successfully shutdown\n\n");
		fflush(stdout);
	}
	return 0;
}



/* This routine initializes all the arguments passed to M */

void init_args(gtm_int_t in1, gtm_uint_t in2, gtm_long_t in3, gtm_ulong_t in4, gtm_float_t in5, gtm_double_t in6,
	       gtm_char_t *in7, gtm_char_t *in8, gtm_int_t *a1, gtm_uint_t *a2, gtm_long_t *a3, gtm_ulong_t *a4,
	       gtm_float_t *a5, gtm_double_t *a6, gtm_char_t *a7, gtm_char_t *inbuf, gtm_string_t *a8)
{
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

