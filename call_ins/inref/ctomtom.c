/****************************************************************
*								*
 * Copyright (c) 2003-2015 Fidelity National Information 	*
 * Services, Inc. and/or its subsidiaries. All rights reserved.	*
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
#include "shrenv.h"

int main()
{
	gtm_status_t status;
	char err[500];
	gtm_long_t val,base1,base2;
	gtm_char_t nval[30];
	val=10300,base1=10,base2=16;

	status = gtm_init();
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	status = gtm_ci("chngbase",nval,val,base1,base2);
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	PRINTF("\n%ld in base %ld = %s\n", val,base2,nval);
	status = gtm_exit();
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	return 0;
}
