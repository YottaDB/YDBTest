/****************************************************************
 *								*
 * Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	*
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

#define BASEVAR "^x"

int main()
{
	int		status;
	ydb_buffer_t	basevar, value;
	char		valuebuff[1024];
	char		errbuf[ERRBUF_SIZE];

	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	value.buf_addr = &valuebuff[0];
	value.len_alloc = sizeof(valuebuff);
	value.len_used = sizeof(valuebuff);
	memset(valuebuff, 'a', sizeof(valuebuff));
	printf("ydb352.c : Set a spanning node with ydb_set_s()\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb352.c : ydb_set_s() returned error : %s\n", errbuf);
		fflush(stdout);
		return status;
	}
	printf("ydb352.c : Do a call-in invocation of ydb352.m with ydb_ci() which gets a REC2BIG error\n"); fflush(stdout);
	status = ydb_ci("ydb352");
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb352.c : ydb352.m call-in error: %s\n", errbuf);
		fflush(stdout);
		return status;
	}
	printf("ydb352.c : ydb352.m call-in did not have any error\n");
	return YDB_OK;
}
