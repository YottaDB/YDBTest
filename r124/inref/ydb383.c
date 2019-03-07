/****************************************************************
 *								*
 * Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries. *
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
#include <time.h>
#include <sys/types.h>
#include <unistd.h>

#define ERRBUF_SIZE	1024

#define BASEVAR "^tp1"
#define SUBSCR1	"42"
#define SUBSCR2 "answer:"
#define VALUE1	"A question"
#define VALUE2	"One less than 43"
#define VALUE3 	"Life, the universe, and everything"

char	errbuf[ERRBUF_SIZE];
int	use_simplethreadapi;

int	gvnset();

int main()
{
	int		status;
	ydb_tp2fnptr_t	tp2fn;
	ydb_string_t	zwrarg;
	int             seed;

	/* Initialize random number seed */
	seed = (time(NULL) * getpid());
	srand48(seed);
	use_simplethreadapi = (int)(2 * drand48());
	printf("# Random choice : use_simplethreadapi = %d\n", use_simplethreadapi); fflush(stdout);

	printf("### --------------------------- ###\n");
	printf("### Running gvnset() without TP ###\n");
	printf("### --------------------------- ###\n");
	fflush(stdout);
	gvnset(YDB_NOTTP, NULL);
	printf("\n### --------------------------- ###\n");
	printf("### Running gvnset() inside  TP ###\n");
	printf("### --------------------------- ###\n");
	fflush(stdout);
	tp2fn = &gvnset;
	printf("Entering ydb_tp_s()/ydb_tp_st()\n");
	status = use_simplethreadapi
			? ydb_tp_st(YDB_NOTTP, NULL, tp2fn, NULL, NULL, 0, NULL)
			: ydb_tp_s((ydb_tpfnptr_t)tp2fn, NULL, NULL, 0, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_tp_s()/ydb_tp_st() [1]: status = %d : %s\n", status, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	return YDB_OK;
}

/* Function to set a global variable */
int gvnset(uint64_t tptoken, ydb_buffer_t *errstr)
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
		printf("Running ydb_set_s()/ydb_set_st() to set node %s(%d)\n", BASEVAR, i);
		subscr.len_used = sprintf(subscr.buf_addr, "%d", i);
		status = use_simplethreadapi
				? ydb_set_st(tptoken, NULL, &basevar, 1, &subscr, &value)
				: ydb_set_s(&basevar, 1, &subscr, &value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s()/ydb_set_st() : status = %d : %s\n", status, errbuf);
			fflush(stdout);
			return status;
		}
	}
	YDB_FREE_BUFFER(&subscr);
	YDB_FREE_BUFFER(&value);
	return YDB_OK;
}
