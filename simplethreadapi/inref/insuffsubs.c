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
#include <sys/types.h>	/* needed for "getpid" */
#include <unistd.h>	/* needed for "getpid" and "fork" */
#include <stdlib.h>	/* needed for "drand48" */
#include <time.h>	/* needed for "time" */

#include "libydberrors.h"

#define ERRBUF_SIZE	1024
#define	MAX_SUBS	3

int main()
{
	int		i, j, status, nsubs, outsubscnt, newoutsubscnt, seed;
	ydb_buffer_t	basevar, subs[MAX_SUBS + 1], outsubs[MAX_SUBS + 1], maxsub;
	char		errbuf[ERRBUF_SIZE], subsstrlit[MAX_SUBS][3], outsubsstrlit[MAX_SUBS][3]; /* 3 to hold 2 digit decimal # + trailing null char */

	seed = (time(NULL) * getpid());
	srand48(seed);
	for (nsubs = 0; nsubs < MAX_SUBS; nsubs++)
	{
		subs[nsubs].len_used = subs[nsubs].len_alloc = sprintf(subsstrlit[nsubs], "%d", nsubs);
		subs[nsubs].buf_addr = subsstrlit[nsubs];
		outsubs[nsubs].len_used = 0;
		outsubs[nsubs].len_alloc = sizeof(outsubsstrlit[nsubs]);
		outsubs[nsubs].buf_addr = outsubsstrlit[nsubs];
	}
	for (i = 0; i < 2; i++)
	{
		if (0 == i)
		{
			YDB_LITERAL_TO_BUFFER("basevar", &basevar);	/* Test lvn */
		} else
		{
			YDB_LITERAL_TO_BUFFER("^basevar", &basevar);	/* Test gvn */
		}

		/* Set a node for ydb_node_next_st() and ydb_node_previous_st() to return */
		status = ydb_set_st(YDB_NOTTP, &basevar, nsubs, subs, NULL);
		YDB_ASSERT(YDB_OK == status);

		/* Test ydb_node_next_st() */
		/* Randomly choose a subscnt that is < MAX_SUBS so we get INSUFFSUBS error */
		outsubscnt = (MAX_SUBS * drand48());
		status = ydb_node_next_st(YDB_NOTTP, &basevar, 0, NULL, &outsubscnt, outsubs);
		YDB_ASSERT(YDB_ERR_INSUFFSUBS == status);
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_next_st() : varname = %s : outsubscnt = %d : Returned error : %s\n", basevar.buf_addr, outsubscnt, errbuf); fflush(stdout);

		/* Randomly choose a subscnt that is >= MAX_SUBS so we do not get INSUFFSUBS error */
		outsubscnt = MAX_SUBS + ((YDB_MAX_SUBS + 1 - MAX_SUBS) * drand48());
		status = ydb_node_next_st(YDB_NOTTP, &basevar, 0, NULL, &outsubscnt, outsubs);
		YDB_ASSERT(YDB_OK == status);

		/* Test ydb_node_previous_st() */
		YDB_LITERAL_TO_BUFFER("100", &maxsub);	/* Choose a value that is greater than current value of subs[0] = "0" */
		/* Randomly choose a subscnt that is < MAX_SUBS so we get INSUFFSUBS error */
		outsubscnt = (MAX_SUBS * drand48());
		status = ydb_node_previous_st(YDB_NOTTP, &basevar, 1, &maxsub, &outsubscnt, outsubs);
		YDB_ASSERT(YDB_ERR_INSUFFSUBS == status);
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() : varname = %s : outsubscnt = %d : Returned error : %s\n", basevar.buf_addr, outsubscnt, errbuf); fflush(stdout);

		/* Randomly choose a subscnt that is >= MAX_SUBS so we do not get INSUFFSUBS error */
		outsubscnt = MAX_SUBS + ((YDB_MAX_SUBS + 1 - MAX_SUBS) * drand48());
		status = ydb_node_previous_st(YDB_NOTTP, &basevar, 1, &maxsub, &outsubscnt, outsubs);
		YDB_ASSERT(YDB_OK == status);

		/* Kill the set node (cleanup) before next iteration */
		status = ydb_delete_st(YDB_NOTTP, &basevar, nsubs, subs, YDB_DEL_NODE);
		YDB_ASSERT(YDB_OK == status);
	}
	return YDB_OK;
}
