/****************************************************************
*								*
*	Copyright 2006, 2014 Fidelity Information Services, Inc	*
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
	char err[500],string1[150],string2[150];

	strcpy(string1,"ｈｅｌlｏ_3_すべての人間は、4");
	strcpy(string2,"3後漢書𠞉𠟠4");

	PRINTF("***This is the starting point of execution***\n");
	PRINTF("C1(unic2m2c2m.c) in C->M->C->M\n");
	status = gtm_init();
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	PRINTF("In C1:Now gtm_ci('concat',%s,%s) will call into M1\n",string1,string2);
	fflush(stdout);
	status = gtm_ci("concat",string1,string2);
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
