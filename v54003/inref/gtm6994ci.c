#include <string.h> 
#include <limits.h>
#include "gtm_stdio.h"
#include "gtmxc_types.h"
#include "mdef.h"
#include "gtm6994.h"

int main(int argc, char *argv[])
{
    int			i;
    int			init;
    int			longtests=(sizeof longtestvalues) / (sizeof longtestvalues[0]);
    int			ulongtests=(sizeof ulongtestvalues) / (sizeof ulongtestvalues[0]);
    gtm_status_t	status;
    gtm_long_t		longval;
    gtm_ulong_t		ulongval;
    gtm_char_t		errmsg[500];

    PRINTF("\ncallin tests\n\n");

    init = gtm_init();

    for (i=0; i<longtests; i++)
    {
	longval = longtestvalues[i];
#ifdef __osf__
        PRINTF("passing value: %d\n", (int)longval);
#else
        PRINTF("passing value: %ld\n", longval);
#endif
	fflush(stdout);
	status = gtm_ci("callin_long", longval);
	fflush(stdout);
	if (status)
	{
	    gtm_zstatus(&errmsg[0], 800);
	    PRINTF(" %s \n", errmsg);
	    fflush(stdout);
	}
#ifdef __osf__
        PRINTF("passing value: %d\n", (int)longval);
#else
        PRINTF("passing value: %ld\n", longval);
#endif
	fflush(stdout);
	status = gtm_ci("callin_longptr", &longval);
	fflush(stdout);
	if (status)
	{
	    gtm_zstatus(&errmsg[0], 800);
	    PRINTF(" %s \n", errmsg);
	    fflush(stdout);
	}
    }

    PRINTF("\n");
    fflush(stdout);

    for (i=0; i<ulongtests; i++)
    {
	ulongval = ulongtestvalues[i];
#ifdef __osf__
        PRINTF("passing value: %u\n", (unsigned int)ulongval);
#else
        PRINTF("passing value: %lu\n", ulongval);
#endif
	fflush(stdout);
	status = gtm_ci("callin_ulong", ulongval);
	fflush(stdout);
	if (status)
	{
	    gtm_zstatus(&errmsg[0], 800);
	    PRINTF(" %s \n", errmsg);
	    fflush(stdout);
	}
#ifdef __osf__
        PRINTF("passing value: %u\n", (unsigned int)ulongval);
#else
        PRINTF("passing value: %lu\n", ulongval);
#endif
	fflush(stdout);
	status = gtm_ci("callin_ulongptr", &ulongval);
	fflush(stdout);
	if (status)
	{
	    gtm_zstatus(&errmsg[0], 800);
	    PRINTF(" %s \n", errmsg);
	    fflush(stdout);
	}
    }

    return 0;
}
