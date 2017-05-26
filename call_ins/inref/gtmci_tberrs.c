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

#include "gtmxc_types.h"
#include "gtm_stdio.h"


int main()
{
	gtm_status_t status;
	gtm_char_t msg[800], ccode[20];
	gtm_long_t anum=2000;

	status = gtm_init();
	if(status)
	{
		gtm_zstatus(&msg[0],800);
		PRINTF(" %s\n",msg);
	}

	if (gtm_ci("getcode",ccode,anum) !=0 )
	{
		gtm_zstatus(&msg[0],800);
		PRINTF(" %s\n",msg);
	}
	status = gtm_exit();
	if(status)
	{
		gtm_zstatus(&msg[0],800);
		PRINTF(" %s\n",msg);
	}
	return 0;
}
