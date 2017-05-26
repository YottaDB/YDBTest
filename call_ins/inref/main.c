
#include <signal.h>
#include <string.h>
#include "gtm_stdio.h"
#include "gtmxc_types.h"

int main()
{
	int o;
	char buf[1000];
	gtm_status_t s;

	s = gtm_init();
	if (s) {
		gtm_zstatus(&buf[0], 1000);
		PRINTF("%s\n", buf);
	}
 	s = gtm_ci("main");
	if (s) {
		gtm_zstatus(&buf[0], 1000);
		PRINTF("%s\n", buf);
	}
	s = gtm_exit();
	if (s) {
		gtm_zstatus(&buf[0], 1000);
		PRINTF("%s\n", buf);
	}
	return 0;
}
