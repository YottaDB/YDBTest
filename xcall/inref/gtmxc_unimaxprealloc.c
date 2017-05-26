#include <string.h>
#include "shrenv.h"
#include "gtm_stdio.h"
#include "gtmxc_types.h"

#ifdef __MVS__
#pragma export(xc_pre_alloc_a)
#endif

/* Note that without preallocation by default GT.M allocates 100 bytes for  char * type */
void	xc_new_alloc_err (int count, xc_char_t*  arg_prealloca)
{
	char a[1048576];
	int i;
	strcpy(a,"𠞉");
	for(i=2;i<=262143;i++) 
		strcat(a,"𠞉");
	strcpy(arg_prealloca,a);	
	fflush (stdout);

	return;
}

