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

float calcnewrate(void);
double calcnewbal(void);

const int  MAXRECS = 5;
long cnum1 = 10005;

long i, acnum1 = 2221001, acnum2= 2221006;

float intrst,newrate,intytd,newytd;

double lbal,newbal;

char custcode[20];
char *prefcode = "Regular";
gtm_string_t custnam1;

int main()
{
	gtm_status_t status;
	char err[500];

	status = gtm_init();
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
		fflush(stdout);
	}

	if (gtm_ci("build"))
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
		fflush(stdout);
	}

	for(i = acnum1; i <acnum2+1; i++)
	{
		status = gtm_ci("getcode",custcode,i);
		if(status)
		{
			gtm_zstatus(&err[0],500);
			PRINTF(" %s\n",err);
			fflush(stdout);
		}
		if(!strcmp(custcode,prefcode))
		{
			status = gtm_ci("get_int",i,&intrst,&intytd);
			if(status)
			{
				gtm_zstatus(&err[0],500);
				PRINTF(" %s\n",err);
				fflush(stdout);
			}
			status = gtm_ci("get_bal",&lbal,i);
			if(status)
			{
				gtm_zstatus(&err[0],500);
				PRINTF(" %s\n",err);
				fflush(stdout);
			}
			if (i == acnum1)
				PRINTF("\n");
			PRINTF("Balance is: %lf\n",lbal);
			newrate = calcnewrate();
			PRINTF("New rates are: %f\n",newrate);
			newbal = calcnewbal();
			PRINTF("New balance is: %lf\n",newbal);
			newytd = intytd+(newbal-lbal);
			PRINTF("Int accrued YTD is: %f\n",newytd);
			status = gtm_ci("putrec",i,newbal,newrate,newytd);
			if(status)
			{
				gtm_zstatus(&err[0],500);
				PRINTF(" %s\n",err);
				fflush(stdout);
			}
		}
	}
	status = gtm_exit();
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
		fflush(stdout);
	}
	return 0;
}

float calcnewrate(void)
{
	float nrate;
	nrate = intrst+0.01;
	return nrate;
}

double calcnewbal(void)
{
	return (lbal+(lbal*newrate));
}
