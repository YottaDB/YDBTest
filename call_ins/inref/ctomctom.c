/****************************************************************
*								*
*	Copyright 2003, 2014 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include <string.h>
#include "gtm_stdio.h"

#include "gtmxc_types.h"

int main()
{
	gtm_status_t status;
	char err[500];
	gtm_long_t num,root;
	num=81,root=2;

	status = gtm_init();
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	status = gtm_ci("sqroot",num,root);
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}

	status = gtm_exit();
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	return 0;
}
