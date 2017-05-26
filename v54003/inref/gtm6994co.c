/****************************************************************
 *								*
 *	Copyright 2011, 2014 Fidelity Information Services, Inc	*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
#include <limits.h>
#include "gtm_stdio.h"
#include "gtmxc_types.h"
#include "mdef.h"
#include "gtm6994.h"

gtm_int_t longtestcount(int count)
{
    return (sizeof longtestvalues) / (sizeof longtestvalues[0]);
}

gtm_int_t ulongtestcount(int count)
{
    return (sizeof ulongtestvalues) / (sizeof ulongtestvalues[0]);
}

gtm_long_t retlong(int count, gtm_int_t testnum)
{
    gtm_long_t rval = longtestvalues[testnum];
#ifdef __osf__
    PRINTF("returning value: %d\n", (int)rval);
#else
    PRINTF("returning value: %ld\n", rval);
#endif
    fflush(stdout);
    return rval;
}

gtm_status_t longptrout(int count, gtm_int_t testnum, gtm_long_t *outval)
{
    *outval = retlong(1, testnum);
    return 0;
}

gtm_ulong_t retulong(int count, gtm_int_t testnum)
{
    gtm_ulong_t rval = ulongtestvalues[testnum];
#ifdef __osf__
    PRINTF("returning value: %u\n", (unsigned int)rval);
#else
    PRINTF("returning value: %lu\n", rval);
#endif
    fflush(stdout);
    return rval;
}

gtm_status_t ulongptrout(int count, gtm_int_t testnum, gtm_ulong_t *outval)
{
    *outval = retulong(1, testnum);
    return 0;
}

gtm_int_t nestxcall(int parmcount, int depth, int maxdepth)
{
	int	status, ret;
	char	msg[2048];

	status = gtm_ci("callin_nestxcall", &ret, depth, maxdepth);
	if (0 != status )
	{
		gtm_zstatus(msg, 2048);
		fprintf( stderr, "%s\n", msg );
		gtm_exit();
		return status ;
	}
	return ret;
}
