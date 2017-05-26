#include <limits.h>
#include "gtm_stdio.h"
#include "gtm_string.h"
#include "gtmxc_types.h"
#include "shrenv.h"

#define return_value	"returned string structure"

void	xc_void()
{
	PRINTF("xc_void\n");
	fflush(stdout);

	return;
}


void	xc_outlongp(int count, xc_long_t *arg_longp)
{
	PRINTF("xc_outlongp: sizeof(arg_longp) = %d\n", (int)sizeof(arg_longp));

	*arg_longp = -12345;
	PRINTF("\t\tmodified return value = "XC_LONG_FMTSTR"\n", *arg_longp);
	fflush(stdout);

	return;
}

void	xc_outulongp(int count, xc_ulong_t *arg_ulongp)
{
	PRINTF("xc_outulongp: sizeof(arg_ulongp) = %d\n", (int)sizeof(arg_ulongp));

	*arg_ulongp = (xc_ulong_t)ULONG_MAX;
	PRINTF("\t\tmodified return value = "XC_ULONG_FMTSTR"\n", *arg_ulongp);
	fflush(stdout);

	return;
}

void	xc_outintp(int count, xc_int_t *arg_intp)
{
	PRINTF("xc_outintp: sizeof(arg_intp) = %d\n", (int)sizeof(arg_intp));

	*arg_intp = -12345;
	PRINTF("\t\tmodified return value = %d\n", *arg_intp);
	fflush(stdout);

	return;
}

void	xc_outuintp(int count, xc_uint_t *arg_uintp)
{
	PRINTF("xc_outuintp: sizeof(arg_uintp) = %d\n", (int)sizeof(arg_uintp));

	*arg_uintp = (xc_uint_t)UINT_MAX;
	PRINTF("\t\tmodified return value = %u\n", *arg_uintp);
	fflush(stdout);

	return;
}

void	xc_outfloatp(int count, xc_float_t *arg_floatp)
{
	PRINTF("xc_outfloatp: sizeof(arg_floatp) = %d\n", (int)sizeof(arg_floatp));

	*arg_floatp = -123.349;
	PRINTF("\t\tmodified return value = %.3f\n", *arg_floatp);
	fflush(stdout);

	return;
}


void	xc_outdoublep(int count, xc_double_t *arg_doublep)
{
	PRINTF("xc_outdoublep: sizeof(arg_doublep) = %d\n", (int)sizeof(arg_doublep));

	*arg_doublep = -654.321;
	PRINTF("\t\tmodified return value = %.3f\n", *arg_doublep);
	fflush(stdout);

	return;
}

void	xc_outcharpp(int count, xc_char_t **arg_charpp)
{
	*arg_charpp = "C-style returned string";
	PRINTF("\t\tmodified return value = '%s'\n", *arg_charpp);
	fflush(stdout);

	return;
}

void	xc_outstringp(int count, xc_string_t *arg_stringp)
{
	arg_stringp->length = strlen(return_value);
	arg_stringp->address = return_value;
	PRINTF("  returning value = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	fflush(stdout);

	return;
}

void	xc_outstringp2(int count, xc_string_t *arg_stringp)
{
	arg_stringp->length = strlen(return_value);
	memcpy(arg_stringp->address,return_value,strlen(return_value));
	PRINTF("  returning value = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	fflush(stdout);

	return;
}

void	gtm_void()
{
	PRINTF("gtm_void\n");
	fflush(stdout);

	return;
}

void	gtm_outlongp(int count, gtm_long_t *arg_longp)
{
	PRINTF("gtm_outlongp: sizeof(arg_longp) = %d\n", (int)sizeof(arg_longp));

	*arg_longp = -12345;
	PRINTF("\t\tmodified return value = "XC_LONG_FMTSTR"\n", *arg_longp);
	fflush(stdout);

	return;
}

void	gtm_outulongp(int count, gtm_ulong_t *arg_ulongp)
{
	PRINTF("gtm_outulongp: sizeof(arg_ulongp) = %d\n", (int)sizeof(arg_ulongp));

	*arg_ulongp = (gtm_ulong_t)ULONG_MAX;
	PRINTF("\t\tmodified return value = "XC_ULONG_FMTSTR"\n", *arg_ulongp);
	fflush(stdout);

	return;
}

void	gtm_outintp(int count, gtm_int_t *arg_intp)
{
	PRINTF("gtm_outintp: sizeof(arg_intp) = %d\n", (int)sizeof(arg_intp));

	*arg_intp = -12345;
	PRINTF("\t\tmodified return value = %d\n", *arg_intp);
	fflush(stdout);

	return;
}

void	gtm_outuintp(int count, gtm_uint_t *arg_uintp)
{
	PRINTF("gtm_outuintp: sizeof(arg_uintp) = %d\n", (int)sizeof(arg_uintp));

	*arg_uintp = (gtm_uint_t)UINT_MAX;
	PRINTF("\t\tmodified return value = %u\n", *arg_uintp);
	fflush(stdout);

	return;
}

void	gtm_outfloatp(int count, gtm_float_t *arg_floatp)
{
	PRINTF("gtm_outfloatp: sizeof(arg_floatp) = %d\n", (int)sizeof(arg_floatp));

	*arg_floatp = -123.349;
	PRINTF("\t\tmodified return value = %.3f\n", *arg_floatp);
	fflush(stdout);

	return;
}


void	gtm_outdoublep(int count, gtm_double_t *arg_doublep)
{
	PRINTF("gtm_outdoublep: sizeof(arg_doublep) = %d\n", (int)sizeof(arg_doublep));

	*arg_doublep = -654.321;
	PRINTF("\t\tmodified return value = %.3f\n", *arg_doublep);
	fflush(stdout);

	return;
}

void	gtm_outcharpp(int count, gtm_char_t **arg_charpp)
{
	*arg_charpp = "C-style returned string";
	PRINTF("\t\tmodified return value = '%s'\n", *arg_charpp);
	fflush(stdout);

	return;
}

void	gtm_outstringp(int count, gtm_string_t *arg_stringp)
{
	arg_stringp->length = strlen(return_value);
	arg_stringp->address = return_value;
	PRINTF("  returning value = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	fflush(stdout);

	return;
}

void	gtm_outstringp2(int count, gtm_string_t *arg_stringp)
{
	arg_stringp->length = strlen(return_value);
	memcpy(arg_stringp->address,return_value,strlen(return_value));
	PRINTF("  returning value = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	fflush(stdout);

	return;
}
