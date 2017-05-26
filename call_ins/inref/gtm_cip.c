
#include <signal.h>
#include <string.h>
#include "gtmxc_types.h"
#include "gtm_stdio.h"

int main()
{
	char buf[1000];
	gtm_status_t s;
	ci_name_descriptor callin_desc;
	callin_desc.rtn_name.address = "display";
	callin_desc.handle = NULL;

	s = gtm_init();
	if (s) 
	{
		gtm_zstatus(&buf[0], 1000);
		PRINTF("%s\n", buf);
	}
 	s = gtm_cip(&callin_desc); 
	if (s) 
	{
		gtm_zstatus(&buf[0], 1000);
		PRINTF("%s\n", buf);
	}
	/* Subsequent calls for the same routine name will use the implicit handle */
 	s = gtm_cip(&callin_desc); 
	if (s) 
	{
		gtm_zstatus(&buf[0], 1000);
		PRINTF("%s\n", buf);
	}
	s = gtm_exit();
	if (s) 
	{
		gtm_zstatus(&buf[0], 1000);
		PRINTF("%s\n", buf);
	}
	return 0;
}
