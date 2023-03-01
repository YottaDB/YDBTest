/****************************************************************
 *								*
 * Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries. *
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* This is a C program using SimpleThreadAPI to implement ./v62002/inref/simpleapi_threeen1f.c (SimpleAPI).
 * While the SimpleAPI version used multiple processes, this one uses multiple threads in one process.
 * Therefore all ydb_lock_*() calls had to be removed in this version as LOCKS are process-level (not thread-level).
 * M local variables that worked with SimpleAPI no longer work since the local variables are shared across all
 * the threads. These are the high level differences between the SimpleAPI and SimpleThreadAPI versions.
 */

#include "libyottadb.h"	/* for ydb_* macros/prototypes/typedefs */
#include "libydberrors.h"	/* for YDB_ERR_* macros */

#include <stdio.h>	/* for "printf" */
#include <unistd.h>	/* for "sysconf" */
#include <stdlib.h>	/* for "atoi" */
#include <string.h>	/* for "strtok" */
#include <time.h>	/* for "time" */
#include <sys/wait.h>	/* for "waitpid" prototype */
#include <errno.h>	/* for "errno" */

#include <sys/stat.h>	/* needed for "creat" */
#include <fcntl.h>	/* needed for "creat" */
#include <pthread.h>

#include <sys/syscall.h>	/* for "syscall" */

#define	YDB_COPY_BUFF_TO_BUFF(SRC, DST)				\
{								\
	int	copy_done;					\
								\
	YDB_COPY_BUFFER_TO_BUFFER(SRC, DST, copy_done);		\
	YDB_ASSERT(copy_done);					\
}

#define	LOCK_TIMEOUT	(unsigned long long)3600000000000	/* 3600 * 10^9 nanoseconds == 3600 seconds == 1 hour */
#define	MAXTHREADS	32

ydb_buffer_t	ylcl_di, ylcl_ds;
ydb_buffer_t	ygbl_limits, ygbl_count;
ydb_buffer_t	ygbl_reads, ygbl_updates, ygbl_highest, ygbl_result, ygbl_step;

#define	MAXVALUELEN	256

typedef struct {
	int	allfirst;
	int	childnum;
} doblk_t;

typedef struct {
	long long int	reads;
	long long int	updates;
	long long int	highest;
} gvstats_parm_t;

void		dbinit();
void		digitsinit();
void		doblk(int allfirst, int childnum);
void		dostep(int first, int last, gvstats_parm_t *gvstats_parm);
void		inttostr(long long n, ydb_buffer_t *buff);
long long	strtoint(ydb_buffer_t *s);
int		tp_gvstatsincr(uint64_t tptoken, ydb_buffer_t *errstr, void *gvstats_parm);
int		tp_setmaximum(uint64_t tptoken, ydb_buffer_t *errstr, void *i);
void		*childthread(void *threadparm);

/* Find the maximum number of steps for the 3n+1 problem for all integers through two input integers.
 * See http://docs.google.com/View?id=dd5f3337_24gcvprmcw
 * Assumes input format is 3 integers separated by a space with the first integer smaller than the second.
 * The third integer is the number of parallel computation streams.  If it is less than twice the
 * number of CPUs or cores, the parameter is modified to that value.  An optional fourth integer is the
 * sizes of blocks of integers on which spawned child processes operate.  If it is not specified, the
 * block size is approximately the range divided by the number of parallel streams.  If the block size is
 * larger than the range divided by the number of execution streams, it is reduced to that value.
 * No input error checking is done.
 *
 * Although the problem can be solved by using strictly integer subscripts and values, this program is
 * written to show that the YottaDB key-value store can use arbitrary strings for both keys and values -
 * each subscript and value is spelled out using the strings in the program source line labelled "digits".
 * Furthermore, the strings are in a number of international languages when YottaDB is run in UTF-8 mode.
 */
/* Implements M entryref threeen1f^threeen1f */
int main(int argc, char *argv[])
{
	int		blk, i, j, k, s, newk, tmp;
	int		status, streams, count, duration;
	char		linebuff[1024], *lineptr, *ptr;
	int		stat[MAXTHREADS + 1], ret[MAXTHREADS + 1];
	doblk_t		threadparm[MAXTHREADS + 1];
	time_t		startat, endat;
	int		updates, reads;
	int		save_errno;
	pthread_t	thread_id[MAXTHREADS];
	char		valuebuff[MAXVALUELEN], subscrbuff[MAXVALUELEN];
	ydb_buffer_t	value, subscr;


	/* Initialize all array variable names we are planning to later use */
	YDB_LITERAL_TO_BUFFER("^limits", &ygbl_limits);
	YDB_LITERAL_TO_BUFFER("^count", &ygbl_count);
	YDB_LITERAL_TO_BUFFER("^reads", &ygbl_reads);
	YDB_LITERAL_TO_BUFFER("^updates", &ygbl_updates);
	YDB_LITERAL_TO_BUFFER("^highest", &ygbl_highest);
	YDB_LITERAL_TO_BUFFER("^result", &ygbl_result);
	YDB_LITERAL_TO_BUFFER("^step", &ygbl_step);

	YDB_LITERAL_TO_BUFFER("di", &ylcl_di);
	YDB_LITERAL_TO_BUFFER("ds", &ylcl_ds);

	value.buf_addr = valuebuff;
	value.len_alloc = sizeof(valuebuff);
	subscr.buf_addr = subscrbuff;
	subscr.len_alloc = sizeof(subscrbuff);

	digitsinit();	/* Initialize data for conversion between integers and strings */

	/* Determine # of CPUs in system. We will have as many parallel computation streams. */
	streams = (int)sysconf(_SC_NPROCESSORS_ONLN);
	YDB_ASSERT(streams);

	/* At the top level, the program reads and processes input lines, one at a time.  Each line specifies
         * one problem to solve.  Since the program is designed to resume after a crash and reuse partial
         * results computed before the crash, data in the database at the beginning is assumed to be partial
         * results from the previous run.  After computing and writing results for a line, the database is
         * cleared for next line of input or next run of the program.
	 */

        /* Loop forever, read a line (quit on end of file), process that line */
	do
	{
		lineptr = fgets(linebuff, sizeof(linebuff), stdin);
		if (NULL == lineptr)
			break;
		ptr = strtok(lineptr, " ");
		i = atoi(ptr);	/* i - first number on line is starting integer for the problem */

		ptr = strtok(NULL, " ");
		j = atoi(ptr);	/* j - second number on line is ending integer for the problem */
		printf("%d %d", i, j);	/* print starting and ending integers */

		ptr = strtok(NULL, " ");
		k = atoi(ptr);	/* k - third number on input line is number of parallel streams */
		if (streams > k)
			newk = streams;
		else
			newk = k;
		printf(" (%d->%d)", k, newk);	/* print number of execution streams, optionally corrected */
		k = newk;
		YDB_ASSERT(k <= MAXTHREADS);

		ptr = strtok(NULL, " ");
		blk = (NULL != ptr) ? atoi(ptr) : 0;	/* blk - size of blocks of integers is optional fourth piece */
		tmp = (j - i + k) / k;	/* default / maximum block size */
		if (blk && (blk <= tmp))	/* print block size, optionally corrected */
			printf(" %d", blk);
		else
		{
			printf(" (%d->%d)", blk, tmp);	/* print number of execution streams, optionally corrected */
			blk = tmp;
		}

		/* Define blocks of integers for child processes to work on */
		status = ydb_delete_st(YDB_NOTTP, NULL, &ygbl_limits, 0, NULL, YDB_DEL_TREE);
		YDB_ASSERT(YDB_OK == status);
		tmp = i - 1;
		for (count = 1; tmp != j; count++)
		{
			tmp += blk;
			if (tmp > j)
				tmp = j;
			subscr.len_used = sprintf(subscr.buf_addr, "%d", count);
			value.len_used = sprintf(value.buf_addr, "%d", tmp);
			status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_limits, 1, &subscr, &value);
			YDB_ASSERT(YDB_OK == status);
		}

		/* Launch threads */
		value.len_used = sprintf(value.buf_addr, "%d", 0);
		status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_count, 0, NULL, &value);	/* Clear ^count - may have residual value if restarting from crash */
		YDB_ASSERT(YDB_OK == status);
		for (s = 1; s <= k; s++)
		{
			status = ydb_incr_st(YDB_NOTTP, NULL, &ygbl_count, 0, NULL, NULL, &value);	/* Atomic increment of counter in database for thread synchronization */
			YDB_ASSERT(YDB_OK == status);
			threadparm[s].allfirst = i;
			threadparm[s].childnum = s;
			status = pthread_create(&thread_id[s], NULL, childthread, &threadparm[s]);
			YDB_ASSERT(0 == status);
		}

		startat = time(NULL);	/* Get starting time */

		/* Wait for threads to finish */
		for (s = 1; s <= k; s++)
		{
			status = pthread_join(thread_id[s], NULL);
			YDB_ASSERT(0 == status);
		}

		endat = time(NULL);	/* Get ending time - time between startat and endat is the elapsed time */
		duration = (int)(endat - startat);

		status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_result, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		printf(" %s", value.buf_addr);

		status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_highest, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		printf(" %s", value.buf_addr);

		printf(" %d", duration);

		status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_updates, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		updates = atoi(value.buf_addr);
		printf(" %s", value.buf_addr);

		status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_reads, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		reads = atoi(value.buf_addr);
		printf(" %s", value.buf_addr);

		/* If duration is greater than 0 seconds, display update and read rates */
		if (duration)
			printf(" %d %d", updates/duration, reads/duration);

		printf("\n");

		dbinit();	/* Initialize database for next run */
	} while (1);
	return YDB_OK;
}

/* Implements M entryref dbinit^threeen1f */
void	dbinit()
{
	int		status;
	ydb_buffer_t	value;

	YDB_MALLOC_BUFFER(&value, MAXVALUELEN);
	/* Entryref dbinit clears database between lines */
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_count, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_highest, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_reads, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_result, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_step, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_updates, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	YDB_FREE_BUFFER(&value);
	return;
}

/* Implements M entryref digitsinit^threeen1f */
void	digitsinit()
{
	int		i, status;
	char		*digitstrings[10] = {
		"zero",
		"eins",
		"deux",
		"tres",
		"quattro",
		"пять",
		"ستة",
		"सात",
		"捌",
		"ஒன்பது",
	};
	ydb_buffer_t	value, subscr;

	YDB_MALLOC_BUFFER(&value, MAXVALUELEN);
	YDB_MALLOC_BUFFER(&subscr, MAXVALUELEN);
	for (i = 0; i <= 9; i++)
	{
		subscr.len_used = sprintf(subscr.buf_addr, "%s", digitstrings[i]);
		value.len_used = sprintf(value.buf_addr, "%d", i);
		status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_di, 1, &subscr, &value);
		YDB_ASSERT(YDB_OK == status);
		status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_ds, 1, &value, &subscr);
		YDB_ASSERT(YDB_OK == status);
	}
	YDB_FREE_BUFFER(&value);
	YDB_FREE_BUFFER(&subscr);
}

/* Implements M entryref inttostr^threeen1f */
void	inttostr(long long n, ydb_buffer_t *buff)
{
	int			digit, nstrlen, i, len;
	char			nstr[32];
	int			status;
	ydb_buffer_t		tmpvalue1, tmpvalue2;

	YDB_MALLOC_BUFFER(&tmpvalue1, MAXVALUELEN);
	YDB_MALLOC_BUFFER(&tmpvalue2, MAXVALUELEN);
	YDB_ASSERT(0 <= n);
	nstrlen = sprintf(nstr, "%lld", n);
	for (i = 0; i < nstrlen; i++)
	{
		digit = nstr[i] - '0';
		tmpvalue1.len_used = sprintf(tmpvalue1.buf_addr, "%d", digit);
		status = ydb_get_st(YDB_NOTTP, NULL, &ylcl_ds, 1, &tmpvalue1, &tmpvalue2);
		YDB_ASSERT(YDB_OK == status);
		tmpvalue2.buf_addr[tmpvalue2.len_used] = '\0';	/* needed for sprintf below */
		if (0 == i)
			buff->len_used = sprintf(buff->buf_addr, "%s", tmpvalue2.buf_addr);
		else
		{
			len = buff->len_used;
			YDB_ASSERT((len + tmpvalue2.len_used + 1) < MAXVALUELEN);
			len = sprintf(buff->buf_addr + len, " %s", tmpvalue2.buf_addr);
			YDB_ASSERT(len == (1 + tmpvalue2.len_used));
			buff->len_used += len;
		}
	}
	YDB_FREE_BUFFER(&tmpvalue1);
	YDB_FREE_BUFFER(&tmpvalue2);
	return;
}

/* Implements M entryref strtoint^threeen1f */
long long strtoint(ydb_buffer_t *s)
{
	char		*ptr, *lineptr, *saveptr;
	int		curdigit;
	int		status;
	long long	n;
	ydb_buffer_t	tmpvalue3, tmpvalue4;

	YDB_MALLOC_BUFFER(&tmpvalue3, MAXVALUELEN);
	YDB_MALLOC_BUFFER(&tmpvalue4, MAXVALUELEN);
	n = 0;
	lineptr = s->buf_addr;
	lineptr[s->len_used] = '\0';	/* needed for strtok_r */
	for ( ; ; )
	{
		ptr = strtok_r(lineptr, " ", &saveptr);
		if (NULL == ptr)
			break;
		tmpvalue3.len_used = sprintf(tmpvalue3.buf_addr, "%s", ptr);
		status = ydb_get_st(YDB_NOTTP, NULL, &ylcl_di, 1, &tmpvalue3, &tmpvalue4);
		YDB_ASSERT(YDB_OK == status);
		tmpvalue4.buf_addr[tmpvalue4.len_used] = '\0';
		curdigit = atoi(tmpvalue4.buf_addr);
		n = (10 * n) + curdigit;
		lineptr = NULL;
	}
	YDB_FREE_BUFFER(&tmpvalue3);
	YDB_FREE_BUFFER(&tmpvalue4);
	return n;
}

void *childthread(void *threadparm)
{
	doblk(((doblk_t *)threadparm)->allfirst, ((doblk_t *)threadparm)->childnum);
}

/* Implements M entryref doblk^threeen1f */
void	doblk(int allfirst, int childnum)
{
	int		status;
	int		tmp, cnt, first, last;
	unsigned int	data_value;
	ydb_tp2fnptr_t	tp2fn;
	ydb_buffer_t	tmpvalue;
	gvstats_parm_t	gvstats_parm;
	ydb_buffer_t	value, subscr[2];

	/* No need to invoke "digitsinit()" as child thread has access to all local variables of parent thread */

	/* Decrement ^count to say this thread is alive */
	YDB_MALLOC_BUFFER(&tmpvalue, MAXVALUELEN);
	tmpvalue.len_used = sprintf(tmpvalue.buf_addr, "%d", -1);
	status = ydb_incr_st(YDB_NOTTP, NULL, &ygbl_count, 0, NULL, &tmpvalue, NULL);
	YDB_ASSERT(YDB_OK == status);
	YDB_FREE_BUFFER(&tmpvalue);

	gvstats_parm.reads = gvstats_parm.updates = gvstats_parm.highest = 0;	/* Start with zero reads, writes and highest number */

	YDB_MALLOC_BUFFER(&subscr[0], MAXVALUELEN);
	YDB_MALLOC_BUFFER(&subscr[1], MAXVALUELEN);
	YDB_MALLOC_BUFFER(&value, MAXVALUELEN);
	/* Process the next block in ^limits that needs processing; quit when done */
	tmp = 0;
	for ( ; ; )
	{
		tmp++;
		subscr[0].len_used = sprintf(subscr[0].buf_addr, "%d", tmp);
		status = ydb_data_st(YDB_NOTTP, NULL, &ygbl_limits, 1, subscr, &data_value);
		YDB_ASSERT(YDB_OK == status);
		if (0 == data_value)
			break;

		subscr[1].len_used = sprintf(subscr[1].buf_addr, "%d", 1);
		status = ydb_incr_st(YDB_NOTTP, NULL, &ygbl_limits, 2, subscr, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		cnt = atoi(value.buf_addr);
		if (1 != cnt)
			continue;

		subscr[0].len_used = sprintf(subscr[0].buf_addr, "%d", tmp - 1);
		status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_limits, 1, subscr, &value);
		if (YDB_ERR_GVUNDEF != status)
		{
			YDB_ASSERT(YDB_OK == status);
			value.buf_addr[value.len_used] = '\0';
			cnt = atoi(value.buf_addr);
			cnt++;
		} else
			cnt = allfirst;
		first = cnt;

		subscr[0].len_used = sprintf(subscr[0].buf_addr, "%d", tmp);
		status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_limits, 1, subscr, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		cnt = atoi(value.buf_addr);
		last = cnt;
		dostep(first, last, &gvstats_parm);
	}
	YDB_FREE_BUFFER(&subscr[0]);
	YDB_FREE_BUFFER(&subscr[1]);
	YDB_FREE_BUFFER(&value);
	/* Update global statistics inside a transaction */
	tp2fn = &tp_gvstatsincr;
	status = ydb_tp_st(YDB_NOTTP, NULL, tp2fn, &gvstats_parm, NULL, 0, NULL);
	YDB_ASSERT(YDB_OK == status);
	return;
}

/* The following function unconditionally adds the number of reads & writes performed by this thread to the
 * number of reads & writes performed by all threads, and sets the highest for all threads if the
 * highest calculated by this thread is greater than that calculated so far for all threads
 */
int tp_gvstatsincr(uint64_t tptoken, ydb_buffer_t *errstr, void *gvstats_parm)
{
	int		highest_gbl, highest_lcl;
	int		status;
	ydb_buffer_t	value;

	YDB_MALLOC_BUFFER(&value, MAXVALUELEN);
	value.len_used = sprintf(value.buf_addr, "%lld", ((gvstats_parm_t *)gvstats_parm)->reads);
	status = ydb_incr_st(tptoken, errstr, &ygbl_reads, 0, NULL, &value, NULL);
	if (YDB_TP_RESTART == status)
	{
		YDB_FREE_BUFFER(&value);
		return status;
	}
	YDB_ASSERT(YDB_OK == status);

	value.len_used = sprintf(value.buf_addr, "%lld", ((gvstats_parm_t *)gvstats_parm)->updates);
	status = ydb_incr_st(tptoken, errstr, &ygbl_updates, 0, NULL, &value, NULL);
	if (YDB_TP_RESTART == status)
	{
		YDB_FREE_BUFFER(&value);
		return status;
	}
	YDB_ASSERT(YDB_OK == status);

	status = ydb_get_st(tptoken, errstr, &ygbl_highest, 0, NULL, &value);
	if (YDB_TP_RESTART == status)
	{
		YDB_FREE_BUFFER(&value);
		return status;
	}
	if (YDB_ERR_GVUNDEF != status)
	{
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		highest_gbl = atoi(value.buf_addr);
	} else
		highest_gbl = 0;
	if (((gvstats_parm_t *)gvstats_parm)->highest > highest_gbl)
	{
		value.len_used = sprintf(value.buf_addr, "%lld", ((gvstats_parm_t *)gvstats_parm)->highest);
		status = ydb_set_st(tptoken, errstr, &ygbl_highest, 0, NULL, &value);
		if (YDB_TP_RESTART == status)
		{
			YDB_FREE_BUFFER(&value);
			return status;
		}
		YDB_ASSERT(YDB_OK == status);
	}
	YDB_FREE_BUFFER(&value);
	return YDB_OK;
}

/* Implements M entryref dostep^threeen1f */
void	dostep(int first, int last, gvstats_parm_t *gvstats_parm)
{
	long long	current, i;
	long long	tmp1, tmp2;
	int		status;
	long long	highest_lcl;
	unsigned int	data_value;
	long long	n;
	ydb_tp2fnptr_t	tp2fn;
	ydb_buffer_t	value, subscr[1];
	ydb_buffer_t	ylcl_currpath;

	YDB_MALLOC_BUFFER(&subscr[0], MAXVALUELEN);
	YDB_MALLOC_BUFFER(&value, MAXVALUELEN);
	YDB_MALLOC_BUFFER(&ylcl_currpath, MAXVALUELEN);
	/* Make each thread running "dostep" operate on a different local variable name by appending thread-id to "currpath" */
	ylcl_currpath.len_used = sprintf(ylcl_currpath.buf_addr, "currpath%ld", syscall(SYS_gettid));
	for (current = first; current <= last; current++)
	{
		n = current;

		/* Currpath holds path to 1 for current */
		status = ydb_delete_st(YDB_NOTTP, NULL, &ylcl_currpath, 0, NULL, YDB_DEL_TREE);
		YDB_ASSERT(YDB_OK == status);

		/* Go till we reach 1 or a number with a known number of steps */
		for (i = 0; ; i++)
		{
			gvstats_parm->reads++;

			if (1 == n)
				break;

			inttostr(n, &subscr[0]);
			status = ydb_data_st(YDB_NOTTP, NULL, &ygbl_step, 1, subscr, &data_value);
			YDB_ASSERT(YDB_OK == status);
			if (data_value)
				break;

			/* log n as current number in sequence */
			value.len_used = sprintf(value.buf_addr, "%lld", n);
			subscr[0].len_used = sprintf(subscr[0].buf_addr, "%lld", i);
			status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_currpath, 1, subscr, &value);
			YDB_ASSERT(YDB_OK == status);

			/* compute the next number */
			if (0 == (n % 2))
				n = n / 2;
			else
				n = (3 * n) + 1;

			/* see if we have a new highest number reached */
			if (n > gvstats_parm->highest)
				gvstats_parm->highest = n;
		}
		/* if 0 == i we already have an answer for n, nothing to do here */
		if (0 < i)
		{
			if (1 < n)
			{
				inttostr(n, &subscr[0]);
				status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_step, 1, subscr, &value);
				YDB_ASSERT(YDB_OK == status);
				i = i + strtoint(&value);
			}
			/* Atomically set maximum */
			tp2fn = &tp_setmaximum;
			status = ydb_tp_st(YDB_NOTTP, NULL, tp2fn, &i, NULL, 0, NULL);
			YDB_ASSERT(YDB_OK == status);
			subscr[0].len_used = 0;	/* to start $order */
			for ( ; ; )
			{
				status = ydb_subscript_next_st(YDB_NOTTP, NULL, &ylcl_currpath, 1, subscr, &value);
				if (YDB_ERR_NODEEND == status)
					break;
				YDB_ASSERT(YDB_OK == status);
				YDB_ASSERT(0 != value.len_used);
				value.buf_addr[value.len_used] = '\0';
				tmp1 = atoi(value.buf_addr);
				gvstats_parm->updates++;

				YDB_COPY_BUFF_TO_BUFF(&value, &subscr[0]);	/* take a copy before it changes */
				status = ydb_get_st(YDB_NOTTP, NULL, &ylcl_currpath, 1, subscr, &value);
				YDB_ASSERT(YDB_OK == status);
				value.buf_addr[value.len_used] = '\0';
				tmp2 = atoll(value.buf_addr);
				inttostr(tmp2, &subscr[0]);
				inttostr(i - tmp1, &value);
				status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_step, 1, subscr, &value);
				YDB_ASSERT(YDB_OK == status);
				subscr[0].len_used = sprintf(subscr[0].buf_addr, "%lld", tmp1);
			}
		}
	}
	YDB_FREE_BUFFER(&subscr[0]);
	YDB_FREE_BUFFER(&value);
	YDB_FREE_BUFFER(&ylcl_currpath);
}

int tp_setmaximum(uint64_t tptoken, ydb_buffer_t *errstr, void *i)
{
	int		result;
	int		status;
	ydb_buffer_t	value;

	YDB_MALLOC_BUFFER(&value, MAXVALUELEN);
	status = ydb_get_st(tptoken, errstr, &ygbl_result, 0, NULL, &value);
	if (YDB_TP_RESTART == status)
	{
		YDB_FREE_BUFFER(&value);
		return status;
	}
	if (YDB_ERR_GVUNDEF != status)
	{
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		result = atoi(value.buf_addr);
	} else
		result = 0;
	if (*(long long *)i > result)
	{
		value.len_used = sprintf(value.buf_addr, "%lld", *(long long *)i);
		status = ydb_set_st(tptoken, errstr, &ygbl_result, 0, NULL, &value);
		if (YDB_TP_RESTART == status)
		{
			YDB_FREE_BUFFER(&value);
			return status;
		}
		YDB_ASSERT(YDB_OK == status);
	}
	YDB_FREE_BUFFER(&value);
	return YDB_OK;
}
