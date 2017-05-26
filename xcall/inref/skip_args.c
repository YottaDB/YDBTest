/****************************************************************
*								*
*	Copyright 2013 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include "gtm_stdio.h"
#include "gtmxc_types.h"

/* Helper script for the xcall/skip_args test. The below routines are called individually from
 * an M program with the last argument(s) missing.
 */

/* The following macros print certain facts about the specified arguments based on their type and placement in the function's
 * argument list. The END flag should reflect whether the argument's position is beyond the total number of arguments passed.
 * Here is the specific information printed by each of the macros:
 *
 *   IS_ZERO:		Prints 'ZERO' if the argument has a numeric value of 0 and is not a skipped trailing argument; prints
 *   			'NON-ZERO' otherwise.
 *   IS_NULL:		Prints 'NULL' if the argument is a NULL pointer and is not a skipped trailing argument; prints 'NON-NULL'
 *   			otherwise; additionally, if non-NULL, not a skipped trailing argument, and has a value of 0 when
 *   			dereferenced, prints 'ZERO'; prints 'NON-ZERO' otherwise.
 *   IS_NULL_CHAR_SS:	Prints 'NULL' if the argument is a NULL pointer and is not a skipped trailing argument; prints 'NON-NULL'
 *                      otherwise; additionally, if non-NULL, not a skipped trailing argument, and has a value of 0 when
 *                      dereferenced, prints 'ZERO'; prints 'NON-ZERO' otherwise.
 *   IS_NULL_STRING:	Prints 'NULL' if the argument is a NULL pointer and is not a skipped trailing argument; prints 'NON-NULL'
 *                      otherwise; additionally, if non-NULL, not a skipped trailing argument, and the pointer in the 'address'
 *                      field is NULL, prints 'NULL'; prints 'NON-NULL' otherwise; additionally, if non-NULL, not a skipped trailing
 *                      argument, and contains a value of 0 in the 'length' field, prints 'ZERO'; prints 'NON-ZERO' otherwise;
 *                      finally, if non-NULL, not a skipped trailing argument, has a non-NULL pointer in the 'address' field, and
 *                      the 'address' field resolves to a NULL terminator when dereferenced, prints 'ZERO'; prints 'NON-ZERO'
 *                      otherwise.
 */
#define IS_ZERO(ARG, END)		((!END && (0 == ARG)) ? "ZERO" : "NON-ZERO")
#define IS_NULL(ARG, TYPE, END)		((!END && (NULL == ARG)) ? "NULL" : "NON-NULL"), 				\
					((!END && (NULL != ARG) && ('\0' == (char)*(TYPE)ARG)) ? "ZERO" : "NON-ZERO")
#define IS_NULL_CHAR_SS(ARG, END)	((!END && (NULL == ARG)) ? "NULL" : "NON-NULL"), 				\
					((!END && (NULL != ARG) && ('\0' == **ARG)) ? "ZERO" : "NON-ZERO")
#define IS_NULL_STRING(ARG, END)	((!END && (NULL == ARG)) ? "NULL" : "NON-NULL"), 				\
					((!END && (NULL != ARG) && (NULL == ARG->address)) ? "NULL" : "NON-NULL"), 	\
					((!END && (NULL != ARG) && (0 == ARG->length)) ? "ZERO" : "NON-ZERO"), 		\
					((!END && (NULL != ARG) && (NULL != ARG->address)				\
						&& ('\0' == *(char *)ARG->address)) ? "ZERO" : "NON-ZERO")

void testInt(int count, int arg1, int arg2, int arg3)
{
	PRINTF("testInt(%d): %s, %s, and %s\n",
		count, IS_ZERO(arg1, (1 > count)), IS_ZERO(arg2, (2 > count)), IS_ZERO(arg3, (3 > count)));
	fflush(stdout);
}

void testLong(int count, int arg1, long arg2)
{
	PRINTF("testLong(%d): %s and %s\n", count, IS_ZERO(arg1, (1 > count)), IS_ZERO(arg2, (2 > count)));
	fflush(stdout);
}

void testIntStar(int count, double *arg1, int *arg2)
{
	PRINTF("testIntStar(%d): %s(%s) and %s(%s)\n", count,
		IS_NULL(arg1, double *, (1 > count)), IS_NULL(arg2, int *, (2 > count)));
	fflush(stdout);
}

void testLongStar(int count, int arg1, int arg2, long *arg3)
{
	PRINTF("testLongStar(%d): %s, %s, and %s(%s)\n",
		count, IS_ZERO(arg1, (1 > count)), IS_ZERO(arg2, (2 > count)), IS_NULL(arg3, long *, (3 > count)));
	fflush(stdout);
}

void testFloatStar(int count, int arg1, char *arg2, float *arg3, float *arg4, float *arg5)
{
	PRINTF("testFloatStar(%d): %s, %s(%s), %s(%s), %s(%s), and %s(%s)\n",
		count, IS_ZERO(arg1, (1 > count)), IS_NULL(arg2, char *, (2 > count)), IS_NULL(arg3, float *, (3 > count)),
		IS_NULL(arg4, float *, (4 > count)), IS_NULL(arg5, float *, (5 > count)));
	fflush(stdout);
}

void testDoubleStar(int count, int arg1, double *arg2)
{
	PRINTF("testDoubleStar(%d): %s and %s(%s)\n", count, IS_ZERO(arg1, (1 > count)), IS_NULL(arg2, double *, (2 > count)));
	fflush(stdout);
}

void testCharStar(int count, int arg1, char **arg2, int arg3, char *arg4)
{
	PRINTF("testCharStar(%d): %s, %s(%s), %s, and %s(%s)\n",
		count, IS_ZERO(arg1, (1 > count)), IS_NULL_CHAR_SS(arg2, (2 > count)),
		IS_ZERO(arg3, (3 > count)), IS_NULL(arg4, char *, (4 > count)));
	fflush(stdout);
}

void testString(int count, gtm_string_t *arg1, gtm_string_t *arg2, gtm_string_t *arg3)
{
	PRINTF("testString(%d): %s(%s,%s,%s), %s(%s,%s,%s), and %s(%s,%s,%s)\n",
		count, IS_NULL_STRING(arg1, (1 > count)), IS_NULL_STRING(arg2, (2 > count)), IS_NULL_STRING(arg3, (3 > count)));
	fflush(stdout);
}
