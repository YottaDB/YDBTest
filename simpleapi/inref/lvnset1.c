/****************************************************************
 *								*
 * Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	*
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

#define ERRBUF_SIZE	1024

#define BASEVAR "baselv"
#define SUBSCR1	"42"
#define SUBSCR2 "answer:"
#define VALUE1	"A question"
#define VALUE2	"One less than 43"
#define VALUE3 	"Life, the universe, and everything"

/* Test simple sets of unsubscripted and subscripted Local Variables */
int main()
{
	int		status;
	ydb_buffer_t	basevar, subscr1, subscr2, value1, value2, value3;
	char		errbuf[ERRBUF_SIZE];

	/* Initialize varname, subscript, and value buffers */
	LYDB_BUFFER_LITERAL(&basevar, BASEVAR);
	LYDB_BUFFER_LITERAL(&subscr1, SUBSCR1);
	LYDB_BUFFER_LITERAL(&subscr2, SUBSCR2);
	LYDB_BUFFER_LITERAL(&value1, VALUE1);
	LYDB_BUFFER_LITERAL(&value2, VALUE2);
	LYDB_BUFFER_LITERAL(&value3, VALUE3);
	/* Initialize call-in environment */
	status = ydb_init();
	if (0 != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_init: %s\n", errbuf);
		fflush(stdout);
		return 0;
	}
	/* Set a base variable, no subscripts */
	status = ydb_set_s(&value1, 0, &basevar);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [1]: %s\n", errbuf);
		fflush(stdout);
		return 0;
	}
	/* Set single subscript value */
	status = ydb_set_s(&value2, 1, &basevar, &subscr1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [2]: %s\n", errbuf);
		fflush(stdout);
		return 0;
	}
	/* Set two subscript value */
	status = ydb_set_s(&value3, 2, &basevar, &subscr1, &subscr2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [3]: %s\n", errbuf);
		fflush(stdout);
		return 0;
	}
	/* Demonstrate our progress by executing a ZWRITE in a call-in */
	status = ydb_ci("driveZWRITE");
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("driveZWRITE error: %s\n", errbuf);
		fflush(stdout);
		return 0;
	}
	return 0;
}
