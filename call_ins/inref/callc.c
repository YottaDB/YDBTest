#include <stdlib.h>
#include "gtm_stdio.h"
#include "gtmxc_types.h"

int callc(int c, int i, int j, int* o)
{
	char buf[1000];
	gtm_status_t s;
	s = gtm_init();
	if (s) {
		*o = 0;
		gtm_zstatus(&buf[0], 1000);
		PRINTF("%s\n", buf); fflush(stdout);
		return 0;
	}
	s = gtm_ci("entry2", 100, 200, o, 300, 400); 
	if (s) {
		*o = 0;
		gtm_zstatus(&buf[0], 1000);
		PRINTF("%s\n", buf); fflush(stdout);
		return 0;
	}
	s = gtm_ci("entry3"); 
	if (s) {
		*o = 0;
		gtm_zstatus(&buf[0], 1000);
		PRINTF("%s\n", buf); fflush(stdout);
		return 0;
	}
	s = gtm_ci("main");
	if (s) {
		*o = 0;
		gtm_zstatus(&buf[0], 1000);
		PRINTF("%s\n", buf); fflush(stdout);
		return 0;
	}
	return 0;
}
