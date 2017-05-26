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
#include "shrenv.h"

#include "gtm_stdio.h"
#include "gtmxc_types.h"

gtm_float_t calcnewrate(void);
gtm_double_t calcnewbal(void);

gtm_status_t ret;
gtm_long_t cnum1 = 10001;
gtm_ulong_t i,acnum = 2221001;
gtm_float_t intrst,newrate,intytd,newytd;
gtm_double_t acbal,lbal,newbal;
gtm_string_t custnam1;
gtm_char_t custcode[20];
gtm_char_t *prefcode = "Regular";


int main()
{
	int ext,init,ret;
	gtm_char_t errmsg[500];
	gtm_status_t status;


	init= gtm_init();
	if(init != 0)
	{
		fflush(stdout);
		gtm_zstatus(&errmsg[0],500);
		PRINTF("%s \n",errmsg);
		fflush(stdout);
	}
	else
	{
		PRINTF("\nGTM env. successfully initialized\n\n");
		fflush(stdout);
	}
	status = gtm_ci("build");
	if (status)
	{
		gtm_zstatus(&errmsg[0],800);
		PRINTF(" %s \n",errmsg);
	}

	status = gtm_ci("get_bal",&acbal,acnum);
	if (status)
	{
		gtm_zstatus(&errmsg[0],800);
		PRINTF(" %s \n",errmsg);
	}

	PRINTF("\n\n\n");
	PRINTF("\nAcct # %ld currently has $%.2lf",acnum,acbal);
	fflush(stdout);

	for(i = acnum; i <acnum+4; i++)
	{
		status = gtm_ci("getcode",custcode,i);
		if (status)
		{
			gtm_zstatus(&errmsg[0],800);
			PRINTF(" %s \n",errmsg);
		}

		if(!strcmp(custcode,prefcode))
		{
			status = gtm_ci("get_int",i,&intrst,&intytd);
			if (status)
			{
				gtm_zstatus(&errmsg[0],800);
				PRINTF(" %s \n",errmsg);
			}
			status = gtm_ci("get_bal",&lbal,i);
			if (status)
			{
				gtm_zstatus(&errmsg[0],800);
				PRINTF(" %s \n",errmsg);
			}
			newrate = calcnewrate();
			newbal = calcnewbal();
			newytd = intytd+(newbal-lbal);
			status = gtm_ci("putrec",i,newbal,newrate,newytd);
			if (status)
			{
				gtm_zstatus(&errmsg[0],800);
				PRINTF(" %s \n",errmsg);
			}
			fflush(stdout);
		}
	}
	PRINTF("\n\n***************************************\n");
	PRINTF("Acct # %ld now has $%.2lf with %.2f and %.2lf accrued ytd",acnum,newbal,newrate,newytd);
	fflush(stdout);

	status = gtm_ci("get_int",acnum,&intrst,&intytd);
	if (status)
	{
		gtm_zstatus(&errmsg[0],800);
		PRINTF(" %s \n",errmsg);
	}
	fflush(stdout);
	PRINTF("\n\n\n***************************************\n");
	PRINTF("Interest rate is $%.2f\n",intrst);
	PRINTF("Int accrued YTD is $%.2f\n",newytd);
	PRINTF("Interest rate for acct # %ld is currently  %.2f\n",acnum,intrst);
	status = gtm_ci("change_int",acnum,&intrst);
	if (status)
	{
		gtm_zstatus(&errmsg[0],800);
		PRINTF(" %s \n",errmsg);
	}
	PRINTF("New interest rate for acct # %ld is %.2f\n",acnum,intrst);
	fflush(stdout);

	ret = gtm_ci("main");
	if(ret != 0)
	{
		fflush(stdout);
		gtm_zstatus(&errmsg[0],500);
		PRINTF(" %s \n",errmsg);
		fflush(stdout);
	}

	ext = gtm_exit();
	if(ext != 0)
	{
		fflush(stdout);
		gtm_zstatus(&errmsg[0],500);
		PRINTF("%s \n",errmsg);
		fflush(stdout);
	}
	else
	{
		PRINTF("\n\nGTM env. successfully shutdown\n\n");
		fflush(stdout);
	}
	return 0;
}

gtm_float_t calcnewrate(void)
{
	gtm_float_t nrate;
	nrate = intrst+0.01;
	return nrate;
}

double calcnewbal(void)
{
	return (lbal+(lbal*newrate));
}
