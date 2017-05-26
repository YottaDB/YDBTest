/****************************************************************
*								*
*	Copyright 2003, 2013 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include "shrenv.h"
#include "stdlib.h"	/* not using gtm_stdlib.h as it is not distributed */
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

	gtm_status_t ret;
	gtm_char_t err[400];
	
	PRINTF ("xc_inmult: sizeof(arg_floatp) = %lu,\t*arg_floatp = %.3f\n", (long unsigned) sizeof(arg_floatp), *arg_floatp);
	PRINTF ("xc_inmult: sizeof(arg_doublep) = %lu,\t*arg_doublep = %.3f\n", (long unsigned) sizeof(arg_doublep), *arg_doublep);
	PRINTF ("xc_inmult: sizeof(arg_charp) = %lu,\t*arg_charp = '%c'\n", (long unsigned) sizeof(arg_charp), *arg_charp);
	PRINTF ("xc_inmult: sizeof(arg_charpp) = %lu,\t*arg_charpp = '%s'\n", (long unsigned) sizeof(arg_charpp), *arg_charpp);
	PRINTF ("xc_inmult: sizeof(arg_stringp) = %lu,\targ_stringp->length = %ld\n", (long unsigned) sizeof(arg_stringp), arg_stringp->length);
	PRINTF ("\t*arg_stringp = '%.*s'\n", (int)arg_stringp->length, arg_stringp->address);
	PRINTF ("\n\n");

	fflush (stdout);
	gtm_init();
	PRINTF("\nGTM environment initialized within C...\n");
	fflush(stdout);
	if (gtm_ci("divbyzro"))
	{
		gtm_zstatus(&err[0],800);
		PRINTF(" %s \n",err);
	}
	if (gtm_exit() !=0)
	{
		gtm_zstatus(&err[0],400);
		exit(0);
	}
}
