/*	gtmxc_fcn.c - value-returning functions invoked by GT.M external calls.
 *
 *	This module provides one GT.M external call callable function for each
 *	of the supported types, as defined in gtmxc_types.h, that can be returned
 *	by such a function.
 *
 *	Note that none of these functions takes any arguments; this module is
 *	intended to test only the correct handling of function return values.
 *
 *	Also, each function prints its name (and return value, if any) for
 *	easier verification.
 */
#include <limits.h>
#include "gtm_stdio.h"
#include "gtmxc_types.h"
#include "shrenv.h"

/*	xc_void - no return value.
 *
 *	A void function should have no return value.  The result will appear to
 *	the GT.M calling program as an undefined value.
 */


void	xc_void()
{
	PRINTF("xc_void\n");
	fflush(stdout);

	return;
}


/*	xc_fcn_xc_long - return long integer value.
 *
 *	xc_long_t is defined as returning a signed long.
 */

xc_long_t	xc_fcn_xc_long()
{
	xc_long_t	ret_xc_long;

	ret_xc_long = 12345;
	PRINTF("xc_fcn_xc_long: returning "XC_LONG_FMTSTR"\n", ret_xc_long);
	fflush(stdout);

	return ret_xc_long;
}

/*	xc_fcn_xc_ulong - return unsigned long value.
 *
 *	xc_ulong_t is defined as returning an unsigned long.
 */

xc_ulong_t	xc_fcn_xc_ulong()
{
	xc_ulong_t	ret_xc_ulong;

	ret_xc_ulong = (xc_ulong_t)ULONG_MAX;
	PRINTF("xc_fcn_xc_ulong: returning "XC_ULONG_FMTSTR"\n", ret_xc_ulong);
	fflush(stdout);

	return ret_xc_ulong;
}

/*	xc_fcn_xc_int - return integer value.
 *
 *	xc_int_t is defined as returning a 32-bit signed integer.
 */

xc_int_t	xc_fcn_xc_int()
{
	xc_int_t	ret_xc_int;

	ret_xc_int = 12345;
	PRINTF("xc_fcn_xc_int: returning %d\n", ret_xc_int);
	fflush(stdout);

	return ret_xc_int;
}

/*	xc_fcn_xc_uint - return unsigned int value.
 *
 *	xc_uint_t is defined as returning a 32-bit unsigned integer.
 */

xc_uint_t	xc_fcn_xc_uint()
{
	xc_uint_t	ret_xc_uint;

	ret_xc_uint = (xc_uint_t)UINT_MAX;
	PRINTF("xc_fcn_xc_uint: returning %u\n", ret_xc_uint);
	fflush(stdout);

	return ret_xc_uint;
}

/*	xc_fcn_xc_status1 - return success status value.
 *
 *	xc_status_t is defined as a "status value" -- i.e., a value indicating
 *	the success or failure of a function call.  If a non-zero value is returned,
 *	the GT.M calling program should raise an M error.
 */
xc_status_t	xc_fcn_xc_status1()
{
	xc_status_t	ret_xc_status;

	ret_xc_status = 0;
	PRINTF("xc_fcn_xc_status1: returning %d\n", ret_xc_status);
	fflush(stdout);

	return ret_xc_status;
}


/*	xc_fcn_xc_status2 - return failure status value.
 *
 *	xc_status_t is defined as a "status value" -- i.e., a value indicating
 *	the success or failure of a function call.  If a non-zero value is returned,
 *	the GT.M calling program should raise an M error.
 */
xc_status_t	xc_fcn_xc_status2()
{
	xc_status_t	ret_xc_status;

	ret_xc_status = -1;
	PRINTF("xc_fcn_xc_status2: returning %d\n", ret_xc_status);
	fflush(stdout);

	return ret_xc_status;
}

/*	gtm_void - no return value.
 *
 *	A void function should have no return value.  The result will appear to
 *	the GT.M calling program as an undefined value.
 */


void	gtm_void()
{
	PRINTF("gtm_void\n");
	fflush(stdout);

	return;
}


/*	gtm_fcn_gtm_long - return long integer value.
 *
 *	gtm_long_t is defined as returning a signed long.
 */

gtm_long_t	gtm_fcn_gtm_long()
{
	gtm_long_t	ret_gtm_long;

	ret_gtm_long = 12345;
	PRINTF("gtm_fcn_gtm_long: returning "XC_LONG_FMTSTR"\n", ret_gtm_long);
	fflush(stdout);

	return ret_gtm_long;
}

/*	gtm_fcn_gtm_ulong - return unsigned long value.
 *
 *	gtm_ulong_t is defined as returning an unsigned long.
 */

gtm_ulong_t	gtm_fcn_gtm_ulong()
{
	gtm_ulong_t	ret_gtm_ulong;

	ret_gtm_ulong = (gtm_ulong_t)ULONG_MAX;
	PRINTF("gtm_fcn_gtm_ulong: returning "XC_ULONG_FMTSTR"\n", ret_gtm_ulong);
	fflush(stdout);

	return ret_gtm_ulong;
}

/*	gtm_fcn_gtm_int - return integer value.
 *
 *	gtm_int_t is defined as returning a 32-bit signed integer.
 */

gtm_int_t	gtm_fcn_gtm_int()
{
	gtm_int_t	ret_gtm_int;

	ret_gtm_int = 12345;
	PRINTF("gtm_fcn_gtm_int: returning %d\n", ret_gtm_int);
	fflush(stdout);

	return ret_gtm_int;
}

/*	gtm_fcn_gtm_uint - return unsigned int value.
 *
 *	gtm_uint_t is defined as returning a 32-bit unsigned integer.
 */

gtm_uint_t	gtm_fcn_gtm_uint()
{
	gtm_uint_t	ret_gtm_uint;

	ret_gtm_uint = (gtm_uint_t)UINT_MAX; 
	PRINTF("gtm_fcn_gtm_uint: returning %u\n", ret_gtm_uint);
	fflush(stdout);

	return ret_gtm_uint;
}

/*	gtm_fcn_gtm_status1 - return success status value.
 *
 *	gtm_status_t is defined as a "status value" -- i.e., a value indicating
 *	the success or failure of a function call.  If a non-zero value is returned,
 *	the GT.M calling program should raise an M error.
 */
gtm_status_t	gtm_fcn_gtm_status1()
{
	gtm_status_t	ret_gtm_status;

	ret_gtm_status = 0;
	PRINTF("gtm_fcn_gtm_status1: returning %d\n", ret_gtm_status);
	fflush(stdout);

	return ret_gtm_status;
}


/*	gtm_fcn_gtm_status2 - return failure status value.
 *
 *	gtm_status_t is defined as a "status value" -- i.e., a value indicating
 *	the success or failure of a function call.  If a non-zero value is returned,
 *	the GT.M calling program should raise an M error.
 */
gtm_status_t	gtm_fcn_gtm_status2()
{
	gtm_status_t	ret_gtm_status;

	ret_gtm_status = -1;
	PRINTF("gtm_fcn_gtm_status2: returning %d\n", ret_gtm_status);
	fflush(stdout);

	return ret_gtm_status;
}
