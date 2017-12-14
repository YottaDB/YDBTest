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
#include <sys/wait.h>	/* needed for "waitpid" */
#include <time.h>	/* needed for "time()" */
#include <stdlib.h>
#include "libydberrors.h"

#define ERRBUF_SIZE	1024

#define	TESTTIME	15		/* Run tp2.c test for max of 15 seconds */
#define BASEVAR		"^tp2"
#define	NCHILDREN	8
#define	MAXNUMINCRS	1000

/* Use SIGILL below to generate a core when an assertion fails */
#define assert(x) ((x) ? 1 : (fprintf(stderr, "Assert failed at %s line %d : %s\n", __FILE__, __LINE__, #x), kill(getpid(), SIGILL)))

char	errbuf[ERRBUF_SIZE];

int	do_tp(int max);
int	gvnincr();

ydb_buffer_t	basevar, value;
char		valuebuff[16];

/* Function to do a test $increment implemented inside TP across multiple processes using the simpleAPI */
int main(int argc, char *argv[])
{
	int		child, numincrs, cumulincrs, stat[NCHILDREN], ret[NCHILDREN], status;
	unsigned long	result;
	pid_t		child_pid[NCHILDREN];
	time_t		start_time, end_time;

	/* Initialize varname, subscript, and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	value.buf_addr = &valuebuff[0];
	value.len_used = 0;
	value.len_alloc = sizeof(valuebuff);

	/* Run test for a max of TESTTIME seconds and do as many sets as possible */
	start_time = time(NULL);
	numincrs = 10;
	cumulincrs = 0;
	do
	{
		for (child = 0; child < NCHILDREN; child++)
		{
			child_pid[child] = fork(); /* BYPASSOK */
			assert(0 <= child_pid[child]);
			if (0 == child_pid[child])
				return do_tp(numincrs);	/* this is the child */
		}
		for (child = 0; child < NCHILDREN; child++)
		{
			ret[child] = waitpid(child_pid[child], &stat[child], 0);
			assert(-1 != ret[child]);
		}
		cumulincrs += (NCHILDREN * numincrs);
		end_time = time(NULL);
		if (TESTTIME < (end_time - start_time))
			break;
		if (MAXNUMINCRS > numincrs)
			numincrs *= 10;
	} while(1);
	/* List the final value of global BASEVAR. That should be the same irrespective of order of TP operations inside children */
	status = ydb_get_s(&value, 0, &basevar);
	assert(YDB_OK == status);
	result = strtoul(value.buf_addr, NULL, 10);
	if ((int)result == cumulincrs)
		printf("PASS from tp2\n");
	else
		printf("FAIL from tp2 : Expected %s=%d : Actual %s=%d\n", BASEVAR, cumulincrs, BASEVAR, (int)result);
	return YDB_OK;
}

int do_tp(int numincrs)
{
	int		status, i;
	ydb_tpfnptr_t	tpfn;
	ydb_string_t	zwrarg;

	tpfn = &gvnincr;
	for (i = 0; i < numincrs; i++)
	{
		status = ydb_tp_s(NULL, NULL, tpfn, &i);
		assert(YDB_OK == status);
	}
	return YDB_OK;
}

/* Function to set a global variable */
int gvnincr(int *i)
{
	int		status;
	unsigned long	result;

	/* Implement $INCR(^x) */
	status = ydb_get_s(&value, 0, &basevar);
	if (YDB_TP_RESTART == status)
		return status;
	if (YDB_ERR_GVUNDEF != status)
	{
		assert(YDB_OK == status);
		result = strtoul(value.buf_addr, NULL, 10);
		result++;
	} else
		result = (*i + 1);
	value.len_used = sprintf(value.buf_addr, "%d", (int)result);
	status = ydb_set_s(&value, 0, &basevar);
	if (YDB_TP_RESTART == status)
		return status;
	assert(YDB_OK == status);
	return YDB_OK;
}
