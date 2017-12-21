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
#define	MAX_SUBS	32

#define BASEVAR "baselv"
#define SUBSCR1	"42"
#define SUBSCR2 "answer:"
#define VALUE1	"A question"
#define VALUE2	"One less than 43"
#define VALUE3 	"Life, the universe, and everything"

/* Test 32-level (max-deep) subscripts can be set in Local Variables */
int main()
{
	int		status, subs;
	ydb_buffer_t	basevar, subscr[2], value1, value2, value3, subsbuff[MAX_SUBS + 1];
	char		errbuf[ERRBUF_SIZE], subsstrlit[MAX_SUBS][3];	/* 3 to hold 2 digit decimal # + trailing null char */
	ydb_string_t	zwrarg;

	/* Initialize varname, subscript, and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	YDB_STRLIT_TO_BUFFER(&subscr[0], SUBSCR1);
	YDB_STRLIT_TO_BUFFER(&subscr[1], SUBSCR2);
	YDB_STRLIT_TO_BUFFER(&value1, VALUE1);
	YDB_STRLIT_TO_BUFFER(&value2, VALUE2);
	YDB_STRLIT_TO_BUFFER(&value3, VALUE3);
	/* Set a base variable, no subscripts */
	status = ydb_set_s(&basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [1]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Set single subscript value */
	status = ydb_set_s(&basevar, 1, subscr, &value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Set two subscript value */
	status = ydb_set_s(&basevar, 2, subscr, &value3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [3]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Set 32-level deep subscripts */
	for (subs = 0; subs < MAX_SUBS; subs++)
	{
		subsbuff[subs].len_used = sprintf(subsstrlit[subs], "%d", subs);
		subsbuff[subs].buf_addr = subsstrlit[subs];
		status = ydb_set_s(&basevar, subs, subsbuff, &subsbuff[subs]);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s() : subsbuff [%d]: %s\n", subs, errbuf);
			fflush(stdout);
			return YDB_OK;
		}
	}
	/* Demonstrate our progress by executing a ZWRITE in a call-in */
	zwrarg.address = NULL;
	zwrarg.length = 0;
	status = ydb_ci("driveZWRITE", &zwrarg);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("driveZWRITE error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	return YDB_OK;
}
