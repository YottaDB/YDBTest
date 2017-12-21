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
#define TRIGVAR		"^tp2trig"
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
	int		child, i, numincrs, cumulincrs, stat[NCHILDREN], ret[NCHILDREN], status, seed, pass;
	unsigned long	result;
	pid_t		child_pid[NCHILDREN];
	time_t		start_time, end_time, test_time;
	char		*trig_val;
	ydb_buffer_t	subs;
	char		subsbuff[16];

	/* Initialize varname, subscript, and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	value.buf_addr = &valuebuff[0];
	value.len_used = 0;
	value.len_alloc = sizeof(valuebuff);

	/* Run test for a max of TESTTIME seconds and do as many sets as possible */
	seed = (time(NULL) * getpid());
	srand48(seed);
	test_time = (TESTTIME * drand48());
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
		if (test_time < (end_time - start_time))
			break;
		if (MAXNUMINCRS > numincrs)
			numincrs *= 10;
	} while(1);
	/* List the final value of global BASEVAR. That should be the same irrespective of order of TP operations inside children */
	status = ydb_get_s(&basevar, 0, NULL, &value);
	assert(YDB_OK == status);
	result = strtoul(value.buf_addr, NULL, 10);
	if ((int)result != cumulincrs)
		printf("FAIL from tp2 : Expected %s=%d : Actual %s=%d\n", BASEVAR, cumulincrs, BASEVAR, (int)result);
	else
		printf("PASS from tp2\n");
	trig_val = getenv("gtm_test_trigger");
	if ((NULL != trig_val) && atoi(trig_val))
	{	/* "gtm_test_trigger" is defined. Check that ^tp2trig(1) to ^tp2trig(cumulincrs) exists. */
		pass = 0;
		YDB_STRLIT_TO_BUFFER(&basevar, TRIGVAR);
		subs.buf_addr = &subsbuff[0];
		subs.len_used = 0;
		subs.len_alloc = sizeof(subsbuff);
		for (i = 1; i <= cumulincrs; i++)
		{
			subs.len_used = sprintf(subs.buf_addr, "%d", i);
			status = ydb_get_s(&basevar, 1, &subs, &value);
			assert(YDB_OK == status);
			assert(0 == value.len_used);
		}
		/* NARSTODO: Also check that no other ^tp2trig(xxx) node exists.
		 * Need ydb_subscript_next() implemented for that check.
		 */
		printf("PASS from tp2trig\n");
	}
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
		status = ydb_tp_s(tpfn, &i, NULL, NULL);
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
	status = ydb_get_s(&basevar, 0, NULL, &value);
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
	status = ydb_set_s(&basevar, 0, NULL, &value);
	if (YDB_TP_RESTART == status)
		return status;
	assert(YDB_OK == status);
	return YDB_OK;
}
