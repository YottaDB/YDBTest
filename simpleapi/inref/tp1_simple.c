/****************************************************************
 *								*
 * Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries. *
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

#define BASEVAR "^tp1"
#define SUBSCR1	"42"
#define SUBSCR2 "answer:"
#define VALUE1	"A question"
#define VALUE2	"One less than 43"
#define VALUE3 	"Life, the universe, and everything"

char	errbuf[ERRBUF_SIZE];

int	gvnset();

int main()
{
	int		status;
	ydb_tpfnptr_t	tpfn;
	ydb_string_t	zwrarg;

	printf("### Function to do a simple set of 3 Global variable nodes inside of a TP transaction ###\n");
	fflush(stdout);

	tpfn = &gvnset;
	status = ydb_tp_s(tpfn, NULL, NULL, 0, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_tp_s() [1]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* List all lvns created by us inside of TP */
	zwrarg.address = NULL;
	zwrarg.length = 0;
	status = ydb_ci("driveZWRITE", &zwrarg);
	YDB_ASSERT(0 == status);
	/* List all gvns created by us */
	status = ydb_ci("gvnZWRITE");
	YDB_ASSERT(0 == status);
	return YDB_OK;
}

/* Function to set a global variable */
int gvnset()
{
	int		status;
	ydb_buffer_t	basevar, subscr[2], value1, value2, value3, badbasevar;

	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(SUBSCR1, &subscr[0]);
	YDB_LITERAL_TO_BUFFER(SUBSCR2, &subscr[1]);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);
	YDB_LITERAL_TO_BUFFER(VALUE2, &value2);
	YDB_LITERAL_TO_BUFFER(VALUE3, &value3);

	/* Note - no call to ydb_init() to verify it happens automatically */

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
	return YDB_OK;
}
