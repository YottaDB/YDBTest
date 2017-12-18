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

#include <sys/types.h>	/* needed for "kill" in assert */
#include <signal.h>	/* needed for "kill" in assert */
#include <unistd.h>	/* needed for "getpid" in assert */

#define ERRBUF_SIZE	1024

#define BASEVAR "^tp1"
#define SUBSCR1	"42"
#define SUBSCR2 "answer:"
#define VALUE1	"A question"
#define VALUE2	"One less than 43"
#define VALUE3 	"Life, the universe, and everything"

/* Use SIGILL below to generate a core when an assertion fails */
#define assert(x) ((x) ? 1 : (fprintf(stderr, "Assert failed at %s line %d : %s\n", __FILE__, __LINE__, #x), kill(getpid(), SIGILL)))

char	errbuf[ERRBUF_SIZE];

int	gvnset();

/* Function to do a simple set of 3 Global variable nodes (done in "gvnset()") inside of a TP transaction */
int main()
{
	int		status;
	ydb_tpfnptr_t	tpfn;
	ydb_string_t	zwrarg;

	tpfn = &gvnset;
	status = ydb_tp_s(NULL, NULL, tpfn, NULL);
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
	assert(0 == status);
	/* List all gvns created by us */
	status = ydb_ci("gvnZWRITE");
	assert(0 == status);
	return YDB_OK;
}

/* Function to set a global variable */
int gvnset()
{
	int		status;
	ydb_buffer_t	basevar, subscr1, subscr2, value1, value2, value3, badbasevar;

	/* Initialize varname, subscript, and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	YDB_STRLIT_TO_BUFFER(&subscr1, SUBSCR1);
	YDB_STRLIT_TO_BUFFER(&subscr2, SUBSCR2);
	YDB_STRLIT_TO_BUFFER(&value1, VALUE1);
	YDB_STRLIT_TO_BUFFER(&value2, VALUE2);
	YDB_STRLIT_TO_BUFFER(&value3, VALUE3);

	/* Note - no call to ydb_init() to verify it happens automatically */

	/* Set a base variable, no subscripts */
	status = ydb_set_s(&value1, 0, &basevar);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [1]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Set single subscript value */
	status = ydb_set_s(&value2, 1, &basevar, &subscr1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Set two subscript value */
	status = ydb_set_s(&value3, 2, &basevar, &subscr1, &subscr2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [3]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	return YDB_OK;
}
