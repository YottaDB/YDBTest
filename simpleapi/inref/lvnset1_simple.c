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
#define BADBASEVAR3 "1namestartswithdigit"
#define BASEVAR "baselv"
#define SUBSCR1	"42"
#define SUBSCR2 "answer:"
#define SUBSCR32 "x"
#define VALUE1	"A question"
#define VALUE2	"One less than 43"
#define VALUE3 	"Life, the universe, and everything"

int main()
{
	int		i, status;
	ydb_buffer_t	basevar, subscr[2], subscr32[32], value1, value2, value3, badbasevar;
	ydb_string_t	zwrarg;
	char		errbuf[ERRBUF_SIZE];

	printf("# Test simple sets in ydb_set_s() of Local Variables\n"); fflush(stdout);
	/* Initialize varname, subscript, and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	YDB_STRLIT_TO_BUFFER(&subscr[0], SUBSCR1);
	YDB_STRLIT_TO_BUFFER(&subscr[1], SUBSCR2);
	YDB_STRLIT_TO_BUFFER(&value1, VALUE1);
	YDB_STRLIT_TO_BUFFER(&value2, VALUE2);
	YDB_STRLIT_TO_BUFFER(&value3, VALUE3);
	printf("Initialize call-in environment\n"); fflush(stdout);
	status = ydb_init();
	if (0 != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_init: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Set a local variable with 0 subscripts\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [1]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Set a local variable with 1 subscript\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 1, subscr, &value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Set a local variable with 2 subscripts\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 2, subscr, &value3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [3]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Demonstrate our progress by executing a ZWRITE in a call-in\n"); fflush(stdout);
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
	return YDB_OK;
}
