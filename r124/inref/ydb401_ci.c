/****************************************************************
 *								*
 * Copyright (c) 2017-2019 YottaDB LLC. and/or its subsidiaries.*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include "libyottadb.h"

#include <stdio.h>
#include <string.h>

#define ERRBUF_SIZE	1024

char	errbuf[ERRBUF_SIZE];

int main()
{
	int 	status;

	printf("# Attempting to make call-in to M\n"); fflush(stdout);
	status = ydb_ci("ydb401");
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line %d: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	return YDB_OK;
}
