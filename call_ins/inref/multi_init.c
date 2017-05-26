/****************************************************************
*								*
*	Copyright 2009, 2014 Fidelity Information Services, Inc	*
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
	xc_long_t val, result;
	val = 100;
	PRINTF("##### gtm_init #####\n");
	status = gtm_init();
	fflush(stdout);
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	PRINTF("##### gtm_ci #####\n");
	status = gtm_ci("square",&result, val);
	fflush(stdout);
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	PRINTF("Square of %ld =  %ld\n", val,result);
	PRINTF("##### gtm_exit #####\n");
	status = gtm_exit();
	fflush(stdout);
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	val=200, result = 0;
	PRINTF("##### gtm_init #####\n");
	fflush(stdout);
	status = gtm_init();
	fflush(stdout);
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	PRINTF("##### gtm_ci #####\n");
	fflush(stdout);
	status = gtm_ci("square",&result, val);
	fflush(stdout);
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	PRINTF("Square of %ld =  %ld\n", val,result);
	PRINTF("##### gtm_exit #####\n");
	status = gtm_exit();
	fflush(stdout);
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	fflush(stdout);
	return 0;
}
