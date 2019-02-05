/****************************************************************
 *								*
 * Copyright (c) 2018-2019 YottaDB LLC. and/or its subsidiaries.*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include "gtmxc_types.h"
#include <stdio.h>
#include <string.h>

#define ERRBUF_SIZE	1024


int main(void)
{
	int			status;
	char			errbuf[ERRBUF_SIZE];
	ci_name_descriptor	test_cid;

	test_cid.rtn_name.address = ("Test");
	test_cid.rtn_name.length = strlen(test_cid.rtn_name.address);
	test_cid.handle = NULL;

	printf("\n# Testing gtm_init()\n"); fflush(stdout);
	status = gtm_init();
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("[Line %d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("\n# Testing gtm_ci()\n"); fflush(stdout);
	status = gtm_ci("Test");
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("[Line %d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("\n\n# Testing gtm_cip()\n"); fflush(stdout);
	status = gtm_cip(&test_cid);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("[Line %d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	return YDB_OK;
}
