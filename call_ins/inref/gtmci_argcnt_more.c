/****************************************************************
*								*
*	Copyright 2004, 2014 Fidelity Information Services, Inc	*
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
	gtm_status_t ret;
	gtm_char_t msg[800];

	gtm_long_t arg1=1,arg2=22,arg3=333,arg4=4444,arg5=55555;

	ret = gtm_init();
	if(ret)
	{
		gtm_zstatus(&msg[0],800);
		PRINTF(" %s\n",msg);
	}

	if(gtm_ci("more_actual",arg1,arg2,arg3,arg4,arg5) != 0)
	{
		gtm_zstatus(&msg[0],800);
		PRINTF(" %s \n",msg);
	}

	ret = gtm_exit();
	if(ret)
	{
		gtm_zstatus(&msg[0],800);
		PRINTF(" %s\n",msg);
	}
	return 0;
}
