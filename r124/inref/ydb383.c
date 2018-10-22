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

	printf("### --------------------------- ###\n");
	printf("### Running gvnset() without TP ###\n");
	printf("### --------------------------- ###\n");
	fflush(stdout);
	gvnset();
	printf("\n### --------------------------- ###\n");
	printf("### Running gvnset() inside  TP ###\n");
	printf("### --------------------------- ###\n");
	fflush(stdout);
	tpfn = &gvnset;
	printf("Entering ydb_tp_s()\n");
	status = ydb_tp_s(tpfn, NULL, NULL, 0, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_tp_s() [1]: status = %d : %s\n", status, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	return YDB_OK;
}

/* Function to set a global variable */
int gvnset()
{
	int		status, i;
	ydb_buffer_t	basevar, subscr, value;

	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);

	/* Note: ydb_init() call not normally needed but needed here because YDB_MALLOC_BUFFER requires it until #205 is fixed */
	ydb_init();

	YDB_MALLOC_BUFFER(&subscr, 64);
	YDB_MALLOC_BUFFER(&value, 200);
	value.len_used = value.len_alloc;
	/* Set single subscript value */
	for (i = 0; i < 20; i++)
	{
		printf("Running ydb_set_s() to set node %s(%d)\n", BASEVAR, i);
		subscr.len_used = sprintf(subscr.buf_addr, "%d", i);
		status = ydb_set_s(&basevar, 1, &subscr, &value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s() : status = %d : %s\n", status, errbuf);
			fflush(stdout);
			return status;
		}
	}
	YDB_FREE_BUFFER(&subscr);
	YDB_FREE_BUFFER(&value);
	return YDB_OK;
}
