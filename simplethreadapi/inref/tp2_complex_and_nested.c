/****************************************************************
 *								*
 * Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries. *
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
#include <sys/wait.h>	/* needed for "waitpid" */
#include <time.h>	/* needed for "time" */
#include <stdlib.h>	/* needed for "drand48" */
#include "libydberrors.h"

#define ERRBUF_SIZE	1024

#define	TESTTIME	15		/* Run tp2.c test for max of 15 seconds */
#define BASEVAR		"^tp2"
#define TRIGVAR		"^tp2trig"
#define	NCHILDREN	8
#define	MAXNUMINCRS	1000

#define	FALSE	0
#define	TRUE	1

char	errbuf[ERRBUF_SIZE];

int	do_tp(int max);
int	gvnincr();
int	gvnincr2();

ydb_buffer_t	basevar, value;
char		valuebuff[16];
int		use_ydb_incr_s_inside_tp, use_ydb_incr_s_outside_tp;

int main(int argc, char *argv[])
{
	int		child, i, numincrs, cumulincrs, stat[NCHILDREN], ret[NCHILDREN], status, seed, pass;
	unsigned long	result;
	pid_t		child_pid[NCHILDREN];
	time_t		start_time, end_time, test_time;
	char		*trig_val;
	ydb_buffer_t	subs;
	char		subsbuff[16];
	int		iters;

	printf("### Function to test $increment implemented inside TP across multiple processes using ydb_tp_st()###\n");
	printf("### Function to also test nested TP calls through ydb_tp_st()###\n");
	fflush(stdout);

	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
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
	/* Use SimpleAPI calls in the parent before the fork. This is because if we use SimpleThreadAPI we will
	 * have to do an exec() after the fork() (or else a STAPIFORKEXEC error is issued). Once we fork off, we
	 * can start using SimpleThreadAPI in the child (which is the bulk of the test).
	 */
	for (iters = 0; ; iters++)
	{
		for (child = 0; child < NCHILDREN; child++)
		{
			fflush(NULL);
			child_pid[child] = fork();
			YDB_ASSERT(0 <= child_pid[child]);
			if (0 == child_pid[child])
				return do_tp(numincrs);	/* this is the child */
		}
		for (child = 0; child < NCHILDREN; child++)
		{
			ret[child] = waitpid(child_pid[child], &stat[child], 0);
			YDB_ASSERT(-1 != ret[child]);
		}
		cumulincrs += (NCHILDREN * numincrs);
		/* Check the value of global BASEVAR after each iteration. That should be the same irrespective of order of TP operations inside children */
		status = ydb_get_s(&basevar, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		result = strtoul(value.buf_addr, NULL, 10);
		if ((int)result != cumulincrs)
		{
			printf("FAIL from tp2 : Expected %s=%d : Actual %s=%d\n", BASEVAR, cumulincrs, BASEVAR, (int)result);
			break;
		}
		end_time = time(NULL);
		if (test_time < (end_time - start_time))
			break;
		if (MAXNUMINCRS > numincrs)
			numincrs *= 10;
	}
	if (cumulincrs)
		printf("PASS from tp2\n");
	trig_val = getenv("gtm_test_trigger");
	if ((NULL != trig_val) && atoi(trig_val))
	{	/* "gtm_test_trigger" is defined. Check that ^tp2trig(1) to ^tp2trig(cumulincrs) exists. */
		pass = 0;
		YDB_LITERAL_TO_BUFFER(TRIGVAR, &basevar);
		subs.buf_addr = &subsbuff[0];
		subs.len_used = 0;
		subs.len_alloc = sizeof(subsbuff);
		for (i = 1; i <= cumulincrs; i++)
		{
			subs.len_used = sprintf(subs.buf_addr, "%d", i);
			status = ydb_get_s(&basevar, 1, &subs, &value);
			YDB_ASSERT(YDB_OK == status);
			YDB_ASSERT(0 == value.len_used);
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
	int		seed, status, i;
	ydb_tp2fnptr_t	tpfn;
	ydb_string_t	zwrarg;

	/* Reset random number seed so all children don't inherit same seed from parent */
	seed = (time(NULL) * getpid());
	srand48(seed);
	use_ydb_incr_s_inside_tp = (2 * drand48());
	use_ydb_incr_s_outside_tp = (2 * drand48());
	tpfn = &gvnincr;
	for (i = 0; i < numincrs; i++)
	{
		if (use_ydb_incr_s_outside_tp)
			status = ydb_incr_st(YDB_NOTTP, NULL, &basevar, 0, NULL, NULL, &value);
		else
			status = ydb_tp_st(YDB_NOTTP, NULL, tpfn, &i, NULL, 0, NULL);
		YDB_ASSERT(YDB_OK == status);
	}
	return YDB_OK;
}

/* Function to do a $increment on a global variable node */
int gvnincr(uint64_t tptoken, ydb_buffer_t *errstr, int *i)	/* $tlevel = 1 TP */
{
	int		status, use_ydb_set_s_inside_nested_tp;
	unsigned long	result;
	ydb_tp2fnptr_t	tpfn2;

	/* Implement $INCR(^x) using ydb_incr_st() or a ydb_get_st()/ydb_set_st() sequence */
	if (use_ydb_incr_s_inside_tp)
		status = ydb_incr_st(tptoken, errstr, &basevar, 0, NULL, NULL, &value);
	else
	{
		status = ydb_get_st(tptoken, errstr, &basevar, 0, NULL, &value);
		if (YDB_TP_RESTART == status)
			return status;
		if (YDB_ERR_GVUNDEF != status)
		{
			YDB_ASSERT(YDB_OK == status);
			value.buf_addr[value.len_used] = '\0';
			result = strtoul(value.buf_addr, NULL, 10);
			result++;
		} else
			result = (*i + 1);
		value.len_used = sprintf(value.buf_addr, "%d", (int)result);
		use_ydb_set_s_inside_nested_tp = (2 * drand48());
		if (!use_ydb_set_s_inside_nested_tp)
			status = ydb_set_st(tptoken, errstr, &basevar, 0, NULL, &value);
		else
		{
			tpfn2 = &gvnincr2;
			status = ydb_tp_st(tptoken, errstr, tpfn2, NULL, NULL, 0, NULL);
		}
	}
	if (YDB_TP_RESTART == status)
		return status;
	YDB_ASSERT(YDB_OK == status);
	return YDB_OK;
}

int gvnincr2(uint64_t tptoken, ydb_buffer_t *errstr, void *ptr)	/* $tlevel = 2 TP (i.e. nested TP) */
{
	int	status;
	int	use_callin;

	use_callin = (2 * drand48());
	if (!use_callin)
		status = ydb_set_st(tptoken, errstr, &basevar, 0, NULL, &value);
	else
		status = ydb_ci_t(tptoken, errstr, "gvnincr2callin");	/* Test TP restarts in C->M and C->M->C->M */
	if (YDB_TP_RESTART == status)
		return status;
	YDB_ASSERT(YDB_OK == status);
	return YDB_OK;
}
