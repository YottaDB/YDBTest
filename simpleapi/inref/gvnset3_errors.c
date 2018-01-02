/****************************************************************
 *								*
 * Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.*
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

#define BADBASEVAR1 "^B%dbasevarInvChar"
#define BADBASEVAR2 "^Verylongbasevarthatexceedsmaxlength"
#define BADBASEVAR3 "^1namestartswithdigit"
#define BASEVAR "^baselv"
#define SUBSCR32 "x"
#define VALUE1	"A question"

int main()
{
	int		i, status;
	ydb_buffer_t	subscr32[32], value1, badbasevar, basevar;
	char		errbuf[ERRBUF_SIZE];

	printf("# Test error scenarios in ydb_set_s() of Global Variables\n"); fflush(stdout);
	/* Initialize varname and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	YDB_STRLIT_TO_BUFFER(&value1, VALUE1);

	/* Now for a few error cases - first up, bad basevar names */
	printf("Attempting set of bad basevar (%% in middle of name) %s\n", BADBASEVAR1);
	fflush(stdout);
	YDB_STRLIT_TO_BUFFER(&badbasevar, BADBASEVAR1);
	status = ydb_set_s(&badbasevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [a]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Attempting set of bad basevar (> 31 characters) %s\n", BADBASEVAR2);
	YDB_STRLIT_TO_BUFFER(&badbasevar, BADBASEVAR2);
	status = ydb_set_s(&badbasevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [b]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Attempting set of bad basevar (first letter in name is digit) %s\n", BADBASEVAR3);
	YDB_STRLIT_TO_BUFFER(&badbasevar, BADBASEVAR3);
	status = ydb_set_s(&badbasevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [c]: %s\n", errbuf);
		fflush(stdout);
	}
	/* Now try setting a non-existent subscript */
	printf("Attempting set of basevar with NULL subscript address parameter where basevar is undefined\n");
	status = ydb_set_s(&basevar, 1, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [d]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Attempting set of basevar with NULL subscript address parameter where basevar is defined\n");
	/* Set a base variable, and then retry the set of a non-existent subscript */
	status = ydb_set_s(&basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [1]: %s\n", errbuf);
		fflush(stdout);
	}
	status = ydb_set_s(&basevar, 1, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [d]: %s\n", errbuf);
		fflush(stdout);
	}
	/* Now try setting > 31 subscripts */
	printf("Attempting set of basevar with 32 subscripts\n");
	for (i = 0; i < 32; i++)
		YDB_STRLIT_TO_BUFFER(&subscr32[i], SUBSCR32);
	status = ydb_set_s(&basevar, 32, subscr32, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [e]: %s\n", errbuf);
		fflush(stdout);
	}
	/* Now try setting < 0 subscripts */
	printf("Attempting set of basevar with -1 subscripts\n");
	status = ydb_set_s(&basevar, -1, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [f]: %s\n", errbuf);
		fflush(stdout);
	}
	/* Test of PARAMINVALID */
	printf("Attempting set with value->len_alloc == 0\n");
	value1.len_alloc = 0;
	status = ydb_set_s(&basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [g]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Attempting set with value->buf_addr == NULL\n");
	YDB_STRLIT_TO_BUFFER(&value1, VALUE1);
	value1.buf_addr = NULL;
	status = ydb_set_s(&basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [h]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Demonstrate our progress by executing a gvnZWRITE in a call-in\n"); fflush(stdout);
	status = ydb_ci("gvnZWRITE");
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("gvnZWRITE error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	return YDB_OK;
}
