#include "shrenv.h"
#include "gtm_stdio.h"

#include "gtmxc_types.h"

void xc_inmult (int		count,
	xc_float_t	*arg_floatp,
	xc_double_t	*arg_doublep,
	xc_char_t	*arg_charp,
	xc_char_t	**arg_charpp,
	xc_string_t	*arg_stringp)
{
	gtm_status_t ret;
	gtm_char_t msg[1000];

	PRINTF ("xc_inmult: sizeof(arg_floatp) = %lu,\t*arg_floatp = %.3f\n", (unsigned long) sizeof(arg_floatp), *arg_floatp);
	PRINTF ("xc_inmult: sizeof(arg_doublep) = %lu,\t*arg_doublep = %.3f\n", (unsigned long) sizeof(arg_doublep), *arg_doublep);
	PRINTF ("xc_inmult: sizeof(arg_charp) = %lu,\t*arg_charp = '%c'\n", (unsigned long) sizeof(arg_charp), *arg_charp);
	PRINTF ("xc_inmult: sizeof(arg_charpp) = %lu,\t*arg_charpp = '%s'\n", (unsigned long) sizeof(arg_charpp), *arg_charpp);
	PRINTF ("xc_inmult: sizeof(arg_stringp) = %lu,\targ_stringp->length = %ld\n", (unsigned long) sizeof(arg_stringp), arg_stringp->length);
	PRINTF ("\t*arg_stringp = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	PRINTF ("\n\n");
	fflush (stdout);

	gtm_init();
	PRINTF("\nGTM environment initialized within C...\n");
	fflush(stdout);
	ret = gtm_ci("divbyzro");
	if(ret != 0)
	{
		fflush(stdout);
		gtm_zstatus(&msg[0],1000);
		PRINTF(" %s \n",msg);
		fflush(stdout);
	}
	return;
}
