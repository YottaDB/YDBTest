#include "gtm_stdio.h"
#include "gtmxc_types.h"
#include "shrenv.h"

void	xc_void ()
{
	PRINTF("xc_void\n");
	fflush(stdout);

	return;
}


void	xc_inlong(int count, xc_long_t arg_long)
{
	PRINTF("pk.xc_inlong: sizeof(arg_long) = %d, arg_long = "XC_LONG_FMTSTR"\n", (int)sizeof(arg_long), arg_long);
	fflush(stdout);

	return;
}

void	xc_inulong(int count, xc_ulong_t arg_ulong)
{
	PRINTF("pk.xc_inulong: sizeof(arg_ulong) = %d, arg_ulong = "XC_ULONG_FMTSTR"\n", (int)sizeof(arg_ulong), arg_ulong);
	fflush(stdout);

	return;
}

void	xc_inlongp(int count, xc_long_t *arg_longp)
{
	PRINTF("pk.xc_inlongp: sizeof(arg_longp) = %d, *arg_longp = "XC_LONG_FMTSTR"\n", (int)sizeof(arg_longp), *arg_longp);
	fflush(stdout);

	return;
}

void	xc_inulongp(int count, xc_ulong_t *arg_ulongp)
{
	PRINTF("pk.xc_inulongp: sizeof(arg_ulongp) = %d, *arg_ulongp = "XC_ULONG_FMTSTR"\n", (int)sizeof(arg_ulongp), *arg_ulongp);
	fflush(stdout);

	return;
}

void	xc_inint(int count, xc_int_t arg_int)
{
	PRINTF("pk.xc_inint: sizeof(arg_int) = %d, arg_int = %d\n", (int)sizeof(arg_int), arg_int);
	fflush(stdout);

	return;
}

void	xc_inuint(int count, xc_uint_t arg_uint)
{
	PRINTF("pk.xc_inuint: sizeof(arg_uint) = %d, arg_uint = %u\n", (int)sizeof(arg_uint), arg_uint);
	fflush(stdout);

	return;
}

void	xc_inintp(int count, xc_int_t *arg_intp)
{
	PRINTF("pk.xc_inintp: sizeof(arg_intp) = %d, *arg_intp = %d\n", (int)sizeof(arg_intp), *arg_intp);
	fflush(stdout);

	return;
}

void	xc_inuintp(int count, xc_uint_t *arg_uintp)
{
	PRINTF("pk.xc_inuintp: sizeof(arg_uintp) = %d, *arg_uintp = %u\n", (int)sizeof(arg_uintp), *arg_uintp);
	fflush(stdout);

	return;
}

void	xc_infloatp(int count, xc_float_t *arg_floatp)
{
	PRINTF("pk.xc_infloatp: sizeof(arg_floatp) = %d, *arg_floatp = %.3f\n", (int)sizeof(arg_floatp), *arg_floatp);
	fflush(stdout);

	return;
}


void	xc_indoublep(int count, xc_double_t *arg_doublep)
{
	PRINTF("pk.xc_indoublep: sizeof(arg_doublep) = %d, *arg_doublep = %.3f\n", (int)sizeof(arg_doublep), *arg_doublep);
	fflush(stdout);

	return;
}


void	xc_incharp(int count, xc_char_t *arg_charp)
{
	PRINTF("pk.xc_incharp: sizeof(arg_charp) = %d, *arg_charp = '%c'\n", (int)sizeof(arg_charp), *arg_charp);
	fflush(stdout);

	return;
}


void	xc_incharpp(int count, xc_char_t **arg_charpp)
{
	PRINTF("pk.xc_incharpp: sizeof(arg_charpp) = %d, *arg_charpp = '%s'\n", (int)sizeof(arg_charpp), *arg_charpp);
	fflush(stdout);

	return;
}


void	xc_instringp(int count, xc_string_t *arg_stringp)
{
	PRINTF("pk.xc_instringp: sizeof(arg_stringp) = %d, arg_stringp->length = "XC_LONG_FMTSTR"\n",
		(int)sizeof(arg_stringp), arg_stringp->length);
	PRINTF("\t*arg_stringp = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	fflush(stdout);

	return;
}

void	gtm_void()
{
	PRINTF("gtm_void\n");
	fflush(stdout);

	return;
}


void	gtm_inlong(int count, gtm_long_t arg_long)
{
	PRINTF("pk.gtm_inlong: sizeof(arg_long) = %d, arg_long = "XC_LONG_FMTSTR"\n", (int)sizeof(arg_long), arg_long);
	fflush(stdout);

	return;
}

void	gtm_inulong(int count, gtm_ulong_t arg_ulong)
{
	PRINTF("pk.gtm_inulong: sizeof(arg_ulong) = %d, arg_ulong = "XC_ULONG_FMTSTR"\n", (int)sizeof(arg_ulong), arg_ulong);
	fflush(stdout);

	return;
}

void	gtm_inlongp(int count, gtm_long_t *arg_longp)
{
	PRINTF("pk.gtm_inlongp: sizeof(arg_longp) = %d, *arg_longp = "XC_LONG_FMTSTR"\n", (int)sizeof(arg_longp), *arg_longp);
	fflush(stdout);

	return;
}

void	gtm_inulongp(int count, gtm_ulong_t *arg_ulongp)
{
	PRINTF("pk.gtm_inulongp: sizeof(arg_ulongp) = %d, *arg_ulongp = "XC_ULONG_FMTSTR"\n", (int)sizeof(arg_ulongp), *arg_ulongp);
	fflush(stdout);

	return;
}

void	gtm_inint(int count, gtm_int_t arg_int)
{
	PRINTF("pk.gtm_inint: sizeof(arg_int) = %d, arg_int = %d\n", (int)sizeof(arg_int), arg_int);
	fflush(stdout);

	return;
}

void	gtm_inuint(int count, gtm_uint_t arg_uint)
{
	PRINTF("pk.gtm_inuint: sizeof(arg_uint) = %d, arg_uint = %u\n", (int)sizeof(arg_uint), arg_uint);
	fflush(stdout);

	return;
}

void	gtm_inintp(int count, gtm_int_t *arg_intp)
{
	PRINTF("pk.gtm_inintp: sizeof(arg_intp) = %d, *arg_intp = %d\n", (int)sizeof(arg_intp), *arg_intp);
	fflush(stdout);

	return;
}

void	gtm_inuintp(int count, gtm_uint_t *arg_uintp)
{
	PRINTF("pk.gtm_inuintp: sizeof(arg_uintp) = %d, *arg_uintp = %u\n", (int)sizeof(arg_uintp), *arg_uintp);
	fflush(stdout);

	return;
}

void	gtm_infloatp(int count, gtm_float_t *arg_floatp)
{
	PRINTF("pk.gtm_infloatp: sizeof(arg_floatp) = %d, *arg_floatp = %.3f\n", (int)sizeof(arg_floatp), *arg_floatp);
	fflush(stdout);

	return;
}


void	gtm_indoublep(int count, gtm_double_t *arg_doublep)
{
	PRINTF("pk.gtm_indoublep: sizeof(arg_doublep) = %d, *arg_doublep = %.3f\n", (int)sizeof(arg_doublep), *arg_doublep);
	fflush(stdout);

	return;
}


void	gtm_incharp(int count, gtm_char_t *arg_charp)
{
	PRINTF("pk.gtm_incharp: sizeof(arg_charp) = %d, *arg_charp = '%c'\n", (int)sizeof(arg_charp), *arg_charp);
	fflush(stdout);

	return;
}


void	gtm_incharpp(int count, gtm_char_t **arg_charpp)
{
	PRINTF("pk.gtm_incharpp: sizeof(arg_charpp) = %d, *arg_charpp = '%s'\n", (int)sizeof(arg_charpp), *arg_charpp);
	fflush(stdout);

	return;
}


void	gtm_instringp(int count, gtm_string_t *arg_stringp)
{
	PRINTF("pk.gtm_instringp: sizeof(arg_stringp) = %d, arg_stringp->length = "XC_LONG_FMTSTR"\n",
		(int)sizeof(arg_stringp), arg_stringp->length);
	PRINTF("\t*arg_stringp = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	fflush(stdout);

	return;
}
