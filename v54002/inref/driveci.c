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
#include "gtm_stdio.h"
#include "gtmxc_types.h"

int main()
{
        gtm_status_t	status;
        char		err[500];

	status = gtm_init();
	if (0 != status)
	{
		gtm_zstatus(&err[0], 500);
		PRINTF(" %s \n", err);
		fflush(stdout);
	}
	if (0 != (status = gtm_ci("simpleci")))	/* Note assignment */
	{
		gtm_zstatus(&err[0], 500);
		PRINTF(" %s \n", err);
		fflush(stdout);
	}
	gtm_exit();
	return 0;
}
