#include <limits.h>
#include "gtm_stdio.h"
#include "gtm_string.h"
#include "gtmxc_types.h"
#include "shrenv.h"

void	xc_void()
{
	PRINTF("xc_void\n");
	fflush(stdout);

	return;
}


void	xc_iolongp(int count, xc_long_t *arg_longp)
{
	PRINTF("xc_iolongp: sizeof(arg_longp) = %d, *arg_longp = "XC_LONG_FMTSTR"\n", (int)sizeof(arg_longp), *arg_longp);

	*arg_longp = -12345;
	PRINTF("\t\tmodified return value = "XC_LONG_FMTSTR"\n", *arg_longp);
	fflush(stdout);

	return;
}

void	xc_ioulongp(int count, xc_ulong_t *arg_ulongp)
{
	PRINTF("xc_ioulongp: sizeof(arg_ulongp) = %d, *arg_ulongp = "XC_ULONG_FMTSTR"\n", (int)sizeof(arg_ulongp), *arg_ulongp);

	*arg_ulongp = (xc_ulong_t)ULONG_MAX;
	PRINTF("\t\tmodified return value = "XC_ULONG_FMTSTR"\n", *arg_ulongp);
	fflush(stdout);

	return;
}

void	xc_iointp(int count, xc_int_t *arg_intp)
{
	PRINTF("xc_iointp: sizeof(arg_intp) = %d, *arg_intp = %d\n", (int)sizeof(arg_intp), *arg_intp);

	*arg_intp = -12345;

	PRINTF("\t\tmodified return value = %d\n", *arg_intp);
	fflush(stdout);

	return;
}

void	xc_iouintp(int count, xc_uint_t *arg_uintp)
{
	PRINTF("xc_iouintp: sizeof(arg_uintp) = %d, *arg_uintp = %u\n", (int)sizeof(arg_uintp), *arg_uintp);

	*arg_uintp = (xc_uint_t)UINT_MAX;

	PRINTF("\t\tmodified return value = %u\n", *arg_uintp);
	fflush(stdout);

	return;
}

void	xc_iofloatp(int count, xc_float_t *arg_floatp)
{
	PRINTF("xc_iofloatp: sizeof(arg_floatp) = %d, *arg_floatp = %.3f\n", (int)sizeof(arg_floatp), *arg_floatp);

	*arg_floatp = -123.349;
	PRINTF("\t\tmodified return value = %.3f\n", *arg_floatp);
	fflush(stdout);

	return;
}


void	xc_iodoublep(int count, xc_double_t *arg_doublep)
{
	PRINTF("xc_iodoublep: sizeof(arg_doublep) = %d, *arg_doublep = %.3f\n", (int)sizeof(arg_doublep), *arg_doublep);

	*arg_doublep = -654.321;
	PRINTF("\t\tmodified return value = %.3f\n", *arg_doublep);
	fflush(stdout);

	return;
}


void	xc_iocharpp(int count, xc_char_t **arg_charpp)
{
	PRINTF("xc_iocharpp: sizeof(arg_charpp) = %d, *arg_charpp = '%s'\n", (int)sizeof(arg_charpp), *arg_charpp);

	*arg_charpp = "C-style returned string";
	PRINTF("\t\tmodified return value = '%s'\n", *arg_charpp);
	fflush(stdout);

	return;
}


#define return_value	"modified string structure"

void	xc_iostringp(int count, xc_string_t *arg_stringp)
{
	PRINTF("xc_iostringp: sizeof(arg_stringp) = %d, arg_stringp->length = "XC_LONG_FMTSTR"\n",
		(int)sizeof(arg_stringp), arg_stringp->length);
	PRINTF("\t*arg_stringp = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);

	arg_stringp->length = strlen(return_value);
	arg_stringp->address = return_value;
	PRINTF("\t\tmodified return value = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	fflush(stdout);

	return;
}

#define return_value2	"modified string"

void	xc_iostringp2(int count, xc_string_t *arg_stringp)
{
	PRINTF("xc_iostringp: sizeof(arg_stringp) = %d, arg_stringp->length = "XC_LONG_FMTSTR"\n",
		(int)sizeof(arg_stringp), arg_stringp->length);
	PRINTF("\t*arg_stringp = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);

	arg_stringp->length = strlen(return_value2);
	memcpy(arg_stringp->address,return_value2,strlen(return_value2));
	PRINTF("\t\tmodified return value = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	fflush(stdout);

	return;
}

void	gtm_void()
{
	PRINTF("gtm_void\n");
	fflush(stdout);

	return;
}


void	gtm_iolongp(int count, gtm_long_t *arg_longp)
{
	PRINTF("gtm_iolongp: sizeof(arg_longp) = %d, *arg_longp = "XC_LONG_FMTSTR"\n", (int)sizeof(arg_longp), *arg_longp);

	*arg_longp = -12345;
	PRINTF("\t\tmodified return value = "XC_LONG_FMTSTR"\n", *arg_longp);
	fflush(stdout);

	return;
}

void	gtm_ioulongp(int count, gtm_ulong_t *arg_ulongp)
{
	PRINTF("gtm_ioulongp: sizeof(arg_ulongp) = %d, *arg_ulongp = "XC_ULONG_FMTSTR"\n", (int)sizeof(arg_ulongp), *arg_ulongp);

	*arg_ulongp = (gtm_ulong_t)ULONG_MAX;
	PRINTF("\t\tmodified return value = "XC_ULONG_FMTSTR"\n", *arg_ulongp);
	fflush(stdout);

	return;
}

void	gtm_iointp(int count, gtm_int_t *arg_intp)
{
	PRINTF("gtm_iointp: sizeof(arg_intp) = %d, *arg_intp = %d\n", (int)sizeof(arg_intp), *arg_intp);

	*arg_intp = -12345;

	PRINTF("\t\tmodified return value = %d\n", *arg_intp);
	fflush(stdout);

	return;
}

void	gtm_iouintp(int count, gtm_uint_t *arg_uintp)
{
	PRINTF("gtm_iouintp: sizeof(arg_uintp) = %d, *arg_uintp = %u\n", (int)sizeof(arg_uintp), *arg_uintp);

	*arg_uintp = (gtm_uint_t)UINT_MAX;

	PRINTF("\t\tmodified return value = %u\n", *arg_uintp);
	fflush(stdout);

	return;
}

void	gtm_iofloatp(int count, gtm_float_t *arg_floatp)
{
	PRINTF("gtm_iofloatp: sizeof(arg_floatp) = %d, *arg_floatp = %.3f\n", (int)sizeof(arg_floatp), *arg_floatp);

	*arg_floatp = -123.349;
	PRINTF("\t\tmodified return value = %.3f\n", *arg_floatp);
	fflush(stdout);

	return;
}


void	gtm_iodoublep(int count, gtm_double_t *arg_doublep)
{
	PRINTF("gtm_iodoublep: sizeof(arg_doublep) = %d, *arg_doublep = %.3f\n", (int)sizeof(arg_doublep), *arg_doublep);

	*arg_doublep = -654.321;
	PRINTF("\t\tmodified return value = %.3f\n", *arg_doublep);
	fflush(stdout);

	return;
}


void	gtm_iocharpp(int count, gtm_char_t **arg_charpp)
{
	PRINTF("gtm_iocharpp: sizeof(arg_charpp) = %d, *arg_charpp = '%s'\n", (int)sizeof(arg_charpp), *arg_charpp);

	*arg_charpp = "C-style returned string";
	PRINTF("\t\tmodified return value = '%s'\n", *arg_charpp);
	fflush(stdout);

	return;
}


#define return_value	"modified string structure"

void	gtm_iostringp(int count, gtm_string_t *arg_stringp)
{
	PRINTF("gtm_iostringp: sizeof(arg_stringp) = %d, arg_stringp->length = "XC_LONG_FMTSTR"\n",
		(int)sizeof(arg_stringp), arg_stringp->length);
	PRINTF("\t*arg_stringp = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);

	arg_stringp->length = strlen(return_value);
	arg_stringp->address = return_value;
	PRINTF("\t\tmodified return value = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	fflush(stdout);

	return;
}

#define return_value2	"modified string"

void	gtm_iostringp2(int count, gtm_string_t *arg_stringp)
{
	PRINTF("gtm_iostringp: sizeof(arg_stringp) = %d, arg_stringp->length = "XC_LONG_FMTSTR"\n",
		(int)sizeof(arg_stringp), arg_stringp->length);
	PRINTF("\t*arg_stringp = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);

	arg_stringp->length = strlen(return_value2);
	memcpy(arg_stringp->address,return_value2,strlen(return_value2));
	PRINTF("\t\tmodified return value = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	fflush(stdout);

	return;
}
