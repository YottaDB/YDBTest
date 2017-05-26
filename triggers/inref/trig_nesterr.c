#include "shrenv.h"
#include <stdio.h>

#include "gtmxc_types.h"

void xc_inmult(int	count,
	xc_float_t	*arg_floatp,
	xc_double_t	*arg_doublep,
	xc_char_t	*arg_charp,
	xc_char_t	**arg_charpp,
	xc_string_t	*arg_stringp)
{
	gtm_status_t ret;
	gtm_char_t msg[1000];

	GTM64_ONLY(
	printf("xc_inmult: sizeof(arg_floatp) = %ld,\t*arg_floatp = %.3f\n", sizeof(arg_floatp), (float )*arg_floatp);
	printf("xc_inmult: sizeof(arg_doublep) = %ld,\t*arg_doublep = %.3f\n", sizeof(arg_doublep), (double )*arg_doublep);
	printf("xc_inmult: sizeof(arg_charp) = %ld,\t*arg_charp = '%c'\n", sizeof(arg_charp), (char )*arg_charp);
	printf("xc_inmult: sizeof(arg_charpp) = %ld,\t*arg_charpp = '%s'\n", sizeof(arg_charpp), (char *)*arg_charpp);
	printf("xc_inmult: sizeof(arg_stringp) = %ld,\targ_stringp->length = %ld\n",sizeof(arg_stringp), arg_stringp->length);
	)
	NON_GTM64_ONLY(
	printf("xc_inmult: sizeof(arg_floatp) = %d,\t*arg_floatp = %.3f\n", sizeof(arg_floatp), (float )*arg_floatp);
	printf("xc_inmult: sizeof(arg_doublep) = %d,\t*arg_doublep = %.3f\n", sizeof(arg_doublep), (double )*arg_doublep);
	printf("xc_inmult: sizeof(arg_charp) = %d,\t*arg_charp = '%c'\n", sizeof(arg_charp), (char )*arg_charp);
	printf("xc_inmult: sizeof(arg_charpp) = %d,\t*arg_charpp = '%s'\n", sizeof(arg_charpp), (char *)*arg_charpp);
	printf("xc_inmult: sizeof(arg_stringp) = %d,\targ_stringp->length = %d\n",sizeof(arg_stringp), (int )arg_stringp->length);
	)
	printf("\t*arg_stringp = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	printf("\n\n");
	fflush(stdout);

	ret = gtm_ci("dtrignsterror");
	if(ret != 0)
	{
		fflush(stdout);
		gtm_zstatus(&msg[0],1000);
		printf(" %s \n",msg);
		fflush(stdout);
	}
	return;
}
