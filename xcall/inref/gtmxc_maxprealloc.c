#include <string.h>
#include "shrenv.h"
#include "gtm_stdio.h"
#include "gtmxc_types.h"

void	xc_new_alloc_1mb (int count, xc_char_t*  arg_prealloca)
{
	FPRINTF(stderr,"sizeof(arg_prealloca) = %d\n", (int) sizeof(arg_prealloca));
	memset(arg_prealloca, 'A',1048576);
	arg_prealloca[1048576] = '\0';
	fflush (stdout);

	return;
}

