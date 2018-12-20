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
#include "libydberrors.h"	/* for YDB_ERR_TPTIMEOUT */
#include <time.h>		/* for "time" prototype */
#include <unistd.h>		/* for "usleep" prototype */

#include <stdio.h>

#define	ERRBUF_SIZE	1024

char		errbuf[ERRBUF_SIZE];
int		gvnset();
char		valuebuff[64];
ydb_buffer_t	ygbl_tp5, yisv_zmaxtptime, value;

int main()
{
	int		status;
	ydb_tp2fnptr_t	tpfn;
	time_t		begin, end;

	printf("### Test timeout in ydb_tp_st() works correctly (TPTIMEOUT error)###\n");
	fflush(stdout);

	value.buf_addr = valuebuff;
	value.len_alloc = sizeof(valuebuff);
	value.len_used = 0;

	printf("Set $zmaxtptime to 1 second\n"); fflush(stdout);
	YDB_LITERAL_TO_BUFFER("$zmaxtptime", &yisv_zmaxtptime);
	YDB_LITERAL_TO_BUFFER("^tp5", &ygbl_tp5);
	value.len_used = sprintf(value.buf_addr, "%d", 1);
	status = ydb_set_st(YDB_NOTTP, &yisv_zmaxtptime, 0, NULL, &value);

	tpfn = &gvnset;
	begin = time(NULL);
	status = ydb_tp_st(YDB_NOTTP, tpfn, NULL, NULL, 0, NULL);
	end = time(NULL);
	YDB_ASSERT(YDB_ERR_TPTIMEOUT == status);
	if (2 < (end - begin))
	{
		printf("Timeout test FAILED for ydb_tp_st() : Timeout expected = 1 second. Actual timeout = %d seconds\n",
			(int)(end - begin)); fflush(stdout);
	} else
	{
		printf("Timeout test PASSED for ydb_tp_st() : Timeout expected = 1 second. Actual timeout = %d seconds\n",
			(int)(end - begin)); fflush(stdout);
	}
	ydb_zstatus(errbuf, ERRBUF_SIZE);
	printf("ydb_tp_st() exit status = %d : %s\n", status, errbuf);
	fflush(stdout);
	return status;
}

/* Function to set a global variable */
int gvnset(uint64_t tptoken)
{
	int	status, i;

	/* We expect a timeout (YDB_ERR_TPTIMEOUT) eventually in this infinite for loop */
	for (i = 0;  ; i++)
	{
		value.len_used = sprintf(value.buf_addr, "%d", i);
		status = ydb_set_st(tptoken, &ygbl_tp5, 1, &value, &value);
		if (YDB_OK != status)
			break;
		usleep(1000);	/* sleep for 1000 microseconds = 1 milli-second */
	}
	return status;
}
