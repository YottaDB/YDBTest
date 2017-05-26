#include "shrenv.h"
#include "gtm_stdio.h"

#include "gtmxc_types.h"

int main()
{

}
void xc_inmult (int		count,
	xc_float_t	*arg_floatp,
	xc_double_t	*arg_doublep,
	xc_char_t	*arg_charp,
	xc_char_t	**arg_charpp,
	xc_string_t	*arg_stringp)
{
	gtm_status_t status;
	GTM64_ONLY(
	PRINTF ("xc_inmult: sizeof(arg_floatp) = %ld,\t*arg_floatp = %.3f\n", sizeof(arg_floatp), *arg_floatp);
	PRINTF ("xc_inmult: sizeof(arg_doublep) = %ld,\t*arg_doublep = %.3f\n", sizeof(arg_doublep), *arg_doublep);
	PRINTF ("xc_inmult: sizeof(arg_charp) = %ld,\t*arg_charp = '%c'\n", sizeof(arg_charp), *arg_charp);
	PRINTF ("xc_inmult: sizeof(arg_charpp) = %ld,\t*arg_charpp = '%s'\n", sizeof(arg_charpp), *arg_charpp);
	PRINTF ("xc_inmult: sizeof(arg_stringp) = %ld,\targ_stringp->length = %d\n",
	sizeof(arg_stringp), arg_stringp->length);
	)
	NON_GTM64_ONLY(
	PRINTF ("xc_inmult: sizeof(arg_floatp) = %d,\t*arg_floatp = %.3f\n", sizeof(arg_floatp), *arg_floatp);
	PRINTF ("xc_inmult: sizeof(arg_doublep) = %d,\t*arg_doublep = %.3f\n", sizeof(arg_doublep), *arg_doublep);
	PRINTF ("xc_inmult: sizeof(arg_charp) = %d,\t*arg_charp = '%c'\n", sizeof(arg_charp), *arg_charp);
	PRINTF ("xc_inmult: sizeof(arg_charpp) = %d,\t*arg_charpp = '%s'\n", sizeof(arg_charpp), *arg_charpp);
	PRINTF ("xc_inmult: sizeof(arg_stringp) = %d,\targ_stringp->length = %d\n",
	sizeof(arg_stringp), arg_stringp->length);
	)
	PRINTF ("\t*arg_stringp = '%.*s'\n", arg_stringp->length, arg_stringp->address);
	PRINTF ("\n\n");
	fflush (stdout);

	gtm_init();
	PRINTF("\nGTM environment initialized within C...\n");
	status = gtm_ci("divbyzro");
	if(status != 0)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s \n",err);
		fflush(stdout);
	}
	return;
}
