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

#define BADBASEVAR1 "B%dbasevarInvChar"
#define BADBASEVAR2 "Verylongbasevarthatexceedsmaxlength"
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
	ydb_buffer_t	basevar, subscr[2], value1, value2, value3, badbasevar;
	ydb_string_t	zwrarg;
	char		errbuf[ERRBUF_SIZE];

	/* Initialize varname, subscript, and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	YDB_STRLIT_TO_BUFFER(&subscr[0], SUBSCR1);
	YDB_STRLIT_TO_BUFFER(&subscr[1], SUBSCR2);
	YDB_STRLIT_TO_BUFFER(&value1, VALUE1);
	YDB_STRLIT_TO_BUFFER(&value2, VALUE2);
	YDB_STRLIT_TO_BUFFER(&value3, VALUE3);
	/* Initialize call-in environment */
	status = ydb_init();
	if (0 != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_init: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Set a base variable, no subscripts */
	status = ydb_set_s(&value1, &basevar, 0, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [1]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Set single subscript value */
	status = ydb_set_s(&value2, &basevar, 1, subscr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Set two subscript value */
	status = ydb_set_s(&value3, &basevar, 2, subscr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [3]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Demonstrate our progress by executing a ZWRITE in a call-in */
	zwrarg.address = NULL;			/* Create a null string argument so dumps all locals */
	zwrarg.length = 0;
	status = ydb_ci("driveZWRITE", &zwrarg);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("driveZWRITE error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Now for a few error cases - first up, bad basevar names */
	printf("Attempting set of bad basevar %s\n", BADBASEVAR1);
	YDB_STRLIT_TO_BUFFER(&badbasevar, BADBASEVAR1);
	status = ydb_set_s(&value1, &badbasevar, 0, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [a]: %s\n", errbuf);
		fflush(stdout);
		/* Keep going after get expected error */
	}
	printf("Attempting set of bad basevar %s\n", BADBASEVAR2);
	YDB_STRLIT_TO_BUFFER(&badbasevar, BADBASEVAR2);
	status = ydb_set_s(&value1, &badbasevar, 0, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [b]: %s\n", errbuf);
		fflush(stdout);
		/* Keep going after get expected error */
	}
	/* Now try sending in a non-existant subscript */
	printf("Attempting set of basevar with NULL subscript address parameter\n");
	status = ydb_set_s(&value1, &basevar, 1, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [c]: %s\n", errbuf);
		fflush(stdout);
	}
	return YDB_OK;
}
