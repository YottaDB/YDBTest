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

#include "libyottadb.h"

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <unistd.h>

#define ERRBUF_SIZE	1024

#define BASEVAR "^x"

int main()
{
	int		status;
	ydb_buffer_t	basevar, value;
	char		valuebuff[1024];
	char		errbuf[ERRBUF_SIZE];
	int		seed, use_simplethreadapi;

	/* Initialize random number seed */
	seed = (time(NULL) * getpid());
	srand48(seed);
	use_simplethreadapi = (int)(2 * drand48());
	printf("# Random choice : use_simplethreadapi = %d\n", use_simplethreadapi); fflush(stdout);

	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	value.buf_addr = &valuebuff[0];
	value.len_alloc = sizeof(valuebuff);
	value.len_used = sizeof(valuebuff);
	memset(valuebuff, 'a', sizeof(valuebuff));
	printf("ydb352.c : Set a spanning node with ydb_set_s()/ydb_set_st()\n"); fflush(stdout);
	status = use_simplethreadapi
				? ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value)
				: ydb_set_s(&basevar, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb352.c : ydb_set_s() returned error : %s\n", errbuf);
		fflush(stdout);
		return status;
	}
	printf("ydb352.c : Do a call-in invocation of ydb352.m with ydb_ci() which gets a REC2BIG error\n"); fflush(stdout);
	status = use_simplethreadapi
				? ydb_ci_t(YDB_NOTTP, NULL, "ydb352")
				: ydb_ci("ydb352");
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
