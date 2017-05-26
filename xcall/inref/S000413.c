#include "gtm_stdio.h"
#include "gtmxc_types.h"
#include "shrenv.h"

/*	xc_inmult - multiple input arguments.
 *
 *	xc_inmult verifies the external call mechanism can handle multiple input arguments.
 */


void xc_inmult(int		count,
		xc_long_t	arg_long,
		xc_long_t	*arg_longp,
		xc_ulong_t	arg_ulong,
		xc_ulong_t	*arg_ulongp,
		xc_int_t	arg_int,
		xc_int_t	*arg_intp,
		xc_uint_t	arg_uint,
		xc_uint_t	*arg_uintp,
		xc_float_t	*arg_floatp,
		xc_double_t	*arg_doublep,
		xc_char_t	*arg_charp,
		xc_char_t	**arg_charpp,
		xc_string_t	*arg_stringp)
{
	PRINTF("xc_inmult: sizeof(arg_long) = %d,\targ_long = "XC_LONG_FMTSTR"\n", (int)sizeof(arg_long), arg_long);
	PRINTF("xc_inmult: sizeof(arg_longp) = %d,\t*arg_longp = "XC_LONG_FMTSTR"\n", (int)sizeof(arg_longp), *arg_longp);
	PRINTF("xc_inmult: sizeof(arg_ulong) = %d,\targ_ulong = "XC_ULONG_FMTSTR"\n", (int)sizeof(arg_ulong), arg_ulong);
	PRINTF("xc_inmult: sizeof(arg_ulongp) = %d,\t*arg_ulongp = "XC_ULONG_FMTSTR"\n", (int)sizeof(arg_ulongp), *arg_ulongp);
	PRINTF("xc_inmult: sizeof(arg_int) = %d,\targ_int = %d\n", (int)sizeof(arg_int), arg_int);
	PRINTF("xc_inmult: sizeof(arg_intp) = %d,\t*arg_intp = %d\n", (int)sizeof(arg_intp), *arg_intp);
	PRINTF("xc_inmult: sizeof(arg_uint) = %d,\targ_uint = %u\n", (int)sizeof(arg_uint), arg_uint);
	PRINTF("xc_inmult: sizeof(arg_uintp) = %d,\t*arg_uintp = %u\n", (int)sizeof(arg_uintp), *arg_uintp);
	PRINTF("xc_inmult: sizeof(arg_floatp) = %d,\t*arg_floatp = %.3f\n", (int)sizeof(arg_floatp), *arg_floatp);
	PRINTF("xc_inmult: sizeof(arg_doublep) = %d,\t*arg_doublep = %.3f\n", (int)sizeof(arg_doublep), *arg_doublep);
	PRINTF("xc_inmult: sizeof(arg_charp) = %d,\t*arg_charp = '%c'\n", (int)sizeof(arg_charp), *arg_charp);
	PRINTF("xc_inmult: sizeof(arg_charpp) = %d,\t*arg_charpp = '%s'\n", (int)sizeof(arg_charpp), *arg_charpp);
	PRINTF("xc_inmult: sizeof(arg_stringp) = %d,\targ_stringp->length = "XC_LONG_FMTSTR"\n",
		(int)sizeof(arg_stringp), arg_stringp->length);
	PRINTF("\t*arg_stringp = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	PRINTF("\n\n");
	fflush(stdout);
	return;
}


/*	xc_inmults - multiple string input arguments.
 *
 *	xc_inmults verifies the external call mechanism can handle multiple string arguments.
 */

void xc_inmults(int		count,
		 xc_string_t	*arg1,
		 xc_string_t	*arg2,
		 xc_string_t	*arg3,
		 xc_string_t	*arg4,
		 xc_string_t	*arg5,
		 xc_string_t	*arg6,
		 xc_string_t	*arg7,
		 xc_string_t	*arg8,
		 xc_string_t	*arg9,
		 xc_string_t	*arg10,
		 xc_string_t	*arg11,
		 xc_string_t	*arg12)
{
	PRINTF("xc_inmults: sizeof(arg1) = %d,\targ1->length = "XC_LONG_FMTSTR"\n",
		(int)sizeof(arg1), arg1->length);
	PRINTF("\t*arg1 = '%.*s'\n", (int)arg1->length, arg1->address);
}
