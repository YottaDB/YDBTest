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

/* This is a C program using simpleAPI to implement v62002/inref/threeen1f.m */

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

#define	YDB_COPY_BUFF_TO_BUFF(SRC, DST)				\
{								\
	int	copy_done;					\
								\
	YDB_COPY_BUFFER_TO_BUFFER(SRC, DST, copy_done);		\
	YDB_ASSERT(copy_done);					\
}

#define	LOCK_TIMEOUT	(unsigned long long)3600000000000	/* 3600 * 10^9 nanoseconds == 3600 seconds == 1 hour */
#define	MAXCHILDREN	32

ydb_buffer_t	ylcl_di, ylcl_ds, ylcl_l1, ylcl_l2;
ydb_buffer_t	ygbl_limits, ygbl_count;
ydb_buffer_t	ygbl_reads, ygbl_updates, ygbl_highest, ygbl_result, ygbl_step;
ydb_buffer_t	ylcl_reads, ylcl_updates, ylcl_highest, ylcl_currpath;
pid_t		process_id;

#define	MAXVALUELEN	256

char		valuebuff[MAXVALUELEN], pidvaluebuff[MAXVALUELEN], tmpvaluebuff[MAXVALUELEN], subscrbuff[YDB_MAX_SUBS + 1][MAXVALUELEN];
ydb_buffer_t	value, tmpvalue, pidvalue, subscr[YDB_MAX_SUBS + 1];

void		dbinit();
void		digitsinit();
void		doblk(int allfirst, int childnum);
void		dostep(int first, int last);
void		inttostr(long long n, ydb_buffer_t *buff);
long long	strtoint(ydb_buffer_t *s);
int		tp_gvstatsincr(void *v);
int		tp_setmaximum();

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
	pid_t		child_pid[MAXCHILDREN + 1];
	int		stat[MAXCHILDREN + 1], ret[MAXCHILDREN + 1];
	time_t		startat, endat;
	int		updates, reads;
	int		save_errno;

	process_id = getpid();
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
	YDB_LITERAL_TO_BUFFER("l1", &ylcl_l1);
	YDB_LITERAL_TO_BUFFER("l2", &ylcl_l2);
	YDB_LITERAL_TO_BUFFER("reads", &ylcl_reads);
	YDB_LITERAL_TO_BUFFER("updates", &ylcl_updates);
	YDB_LITERAL_TO_BUFFER("highest", &ylcl_highest);
	YDB_LITERAL_TO_BUFFER("currpath", &ylcl_currpath);

	value.buf_addr = valuebuff;
	value.len_alloc = sizeof(valuebuff);
	pidvalue.buf_addr = pidvaluebuff;
	pidvalue.len_alloc = sizeof(pidvaluebuff);
	tmpvalue.buf_addr = tmpvaluebuff;
	tmpvalue.len_alloc = sizeof(tmpvaluebuff);
	for (i = 0; i < YDB_MAX_SUBS + 1; i++)
	{
		subscr[i].buf_addr = subscrbuff[i];
		subscr[i].len_alloc = sizeof(subscrbuff[i]);
	}

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

        /* Loop for ever, read a line (quit on end of file), process that line */
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
		YDB_ASSERT(k <= MAXCHILDREN);

		ptr = strtok(NULL, " ");
		blk = atoi(ptr);	/* blk - size of blocks of integers is optional fourth piece */
		tmp = (j - i + k) / k;	/* default / maximum block size */
		if (blk && (blk <= tmp))	/* print block size, optionally corrected */
			printf(" %d", blk);
		else
		{
			printf(" (%d->%d)", blk, tmp);	/* print number of execution streams, optionally corrected */
			blk = tmp;
		}

		/* Define blocks of integers for child processes to work on */
		status = ydb_delete_s(&ygbl_limits, 0, NULL, YDB_DEL_TREE);
		YDB_ASSERT(YDB_OK == status);
		tmp = i - 1;
		for (count = 1; tmp != j; count++)
		{
			tmp += blk;
			if (tmp > j)
				tmp = j;
			subscr[0].len_used = sprintf(subscr[0].buf_addr, "%d", count);
			value.len_used = sprintf(value.buf_addr, "%d", tmp);
			status = ydb_set_s(&ygbl_limits, 1, subscr, &value);
			YDB_ASSERT(YDB_OK == status);
		}

		/* Launch jobs.  Grab lock l1, atomically increment counter, compute and launch one job for each block of numbers.
		 * Each child job locks l2(pid), decrements the counter and tries to grab lock l1(pid).
		 * When counter is zero, all jobs have started.  Parent releases lock l1 and tries to grab lock l2.
		 * When all children have released their l2(pid) locks, they're done and parent can gather & report results.
		 */
		value.len_used = sprintf(value.buf_addr, "%d", 0);
		status = ydb_set_s(&ygbl_count, 0, NULL, &value);	/* Clear ^count - may have residual value if restarting from crash */
		YDB_ASSERT(YDB_OK == status);
		status = ydb_lock_incr_s(LOCK_TIMEOUT, &ylcl_l1, 0, NULL);	/* Set lock for process synchronization */
		YDB_ASSERT(YDB_OK == status);
		for (s = 1; s <= k; s++)
		{
			status = ydb_incr_s(&ygbl_count, 0, NULL, NULL, &value);	/* Atomic increment of counter in database for process synchronization */
			YDB_ASSERT(YDB_OK == status);
			child_pid[s] = fork();
			YDB_ASSERT(0 <= child_pid[s]);
			if (0 == child_pid[s])
			{
				status = ydb_child_init(NULL);	/* needed in child pid right after a fork() */
				YDB_ASSERT(YDB_OK == status);
				doblk(i, s);	/* this is the child */
				return YDB_OK;
			}
		}
		/* Wait for all children to start (^count goes to 0 when they do) */
		for ( ; ; )
		{
			status = ydb_get_s(&ygbl_count, 0, NULL, &value);
			YDB_ASSERT(YDB_OK == status);
			value.buf_addr[value.len_used] = '\0';
			if (0 == atoi(value.buf_addr))
				break;
			sleep(1);
		}
		status = ydb_lock_decr_s(&ylcl_l1, 0, NULL);	/* Release lock so processes can run */
		YDB_ASSERT(YDB_OK == status);

		startat = time(NULL);	/* Get starting time */

		status = ydb_lock_incr_s(LOCK_TIMEOUT, &ylcl_l2, 0, NULL);	/* Wait for processes to finish (may take longer with a poollimit) */
		YDB_ASSERT(YDB_OK == status);

		endat = time(NULL);	/* Get ending time - time between startat and endat is the elapsed time */
		duration = (int)(endat - startat);

		status = ydb_get_s(&ygbl_result, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		printf(" %s", value.buf_addr);

		status = ydb_get_s(&ygbl_highest, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		printf(" %s", value.buf_addr);

		printf(" %d", duration);

		status = ydb_get_s(&ygbl_updates, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		updates = atoi(value.buf_addr);
		printf(" %s", value.buf_addr);

		status = ydb_get_s(&ygbl_reads, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		reads = atoi(value.buf_addr);
		printf(" %s", value.buf_addr);

		/* If duration is greater than 0 seconds, display update and read rates */
		if (duration)
			printf(" %d %d", updates/duration, reads/duration);

		printf("\n");

		status = ydb_lock_decr_s(&ylcl_l2, 0, NULL);	/* Release lock for next run */
		YDB_ASSERT(YDB_OK == status);

		/* Wait for children to terminate */
		for (s = 1; s <= k; s++)
		{
			do
			{
				ret[s] = waitpid(child_pid[s], &stat[s], 0);
				save_errno = errno;
			} while ((-1 == ret[s]) && (EINTR == save_errno));
			YDB_ASSERT(-1 != ret[s]);
		}

		dbinit();	/* Initialize database for next run */
	} while (1);
	return YDB_OK;
}

/* Implements M entryref dbinit^threeen1f */
void	dbinit()
{
	int	status;

	/* Entryref dbinit clears database between lines */
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ygbl_count, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_s(&ygbl_highest, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_s(&ygbl_reads, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_s(&ygbl_result, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_s(&ygbl_step, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_s(&ygbl_updates, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
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

	for (i = 0; i <= 9; i++)
	{
		subscr[0].len_used = sprintf(subscr[0].buf_addr, "%s", digitstrings[i]);
		value.len_used = sprintf(value.buf_addr, "%d", i);
		status = ydb_set_s(&ylcl_di, 1, subscr, &value);
		YDB_ASSERT(YDB_OK == status);
		status = ydb_set_s(&ylcl_ds, 1, &value, subscr);
		YDB_ASSERT(YDB_OK == status);
	}
}

/* Implements M entryref inttostr^threeen1f */
void	inttostr(long long n, ydb_buffer_t *buff)
{
	int			digit, nstrlen, i, len;
	char			nstr[32];
	int			status;
	static ydb_buffer_t	tmpvalue1, tmpvalue2;
	static char		tmpvalue1buff[MAXVALUELEN], tmpvalue2buff[MAXVALUELEN];
	static int		first_time = 1;

	if (first_time)
	{
		tmpvalue1.buf_addr = tmpvalue1buff;
		tmpvalue1.len_alloc = sizeof(tmpvalue1buff);
		tmpvalue2.buf_addr = tmpvalue2buff;
		tmpvalue2.len_alloc = sizeof(tmpvalue2buff);
		first_time = 0;
	}
	YDB_ASSERT(0 <= n);
	nstrlen = sprintf(nstr, "%lld", n);
	for (i = 0; i < nstrlen; i++)
	{
		digit = nstr[i] - '0';
		tmpvalue1.len_used = sprintf(tmpvalue1.buf_addr, "%d", digit);
		status = ydb_get_s(&ylcl_ds, 1, &tmpvalue1, &tmpvalue2);
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
	return;
}

/* Implements M entryref strtoint^threeen1f */
long long strtoint(ydb_buffer_t *s)
{
	char		*ptr, *lineptr;
	int		curdigit;
	int		status;
	long long	n;
	static ydb_buffer_t	tmpvalue3, tmpvalue4;
	static char		tmpvalue3buff[MAXVALUELEN], tmpvalue4buff[MAXVALUELEN];
	static int		first_time2 = 1;

	if (first_time2)
	{
		tmpvalue3.buf_addr = tmpvalue3buff;
		tmpvalue3.len_alloc = sizeof(tmpvalue3buff);
		tmpvalue4.buf_addr = tmpvalue4buff;
		tmpvalue4.len_alloc = sizeof(tmpvalue4buff);
		first_time2 = 0;
	}
	n = 0;
	lineptr = s->buf_addr;
	lineptr[s->len_used] = '\0';	/* needed for strtok */
	for ( ; ; )
	{
		ptr = strtok(lineptr, " ");
		if (NULL == ptr)
			break;
		tmpvalue3.len_used = sprintf(tmpvalue3.buf_addr, "%s", ptr);
		status = ydb_get_s(&ylcl_di, 1, &tmpvalue3, &tmpvalue4);
		YDB_ASSERT(YDB_OK == status);
		tmpvalue4.buf_addr[tmpvalue4.len_used] = '\0';
		curdigit = atoi(tmpvalue4.buf_addr);
		n = (10 * n) + curdigit;
		lineptr = NULL;
	}
	return n;
}

/* Implements M entryref doblk^threeen1f */
void	doblk(int allfirst, int childnum)
{
	int		status;
	int		tmp, cnt, first, last;
	unsigned int	data_value;
	ydb_tpfnptr_t	tpfn;
	int		outfd, errfd, newfd;
	char		outfile[64], errfile[64];

	process_id = getpid();
	pidvalue.len_used = sprintf(pidvalue.buf_addr, "%d", (int)process_id);

	/* Set stdout & stderr to child specific files */
	sprintf(outfile, "simpleapi_threeen1f.mjo%d", childnum);
	outfd = creat(outfile, 0666);
	YDB_ASSERT(-1 != outfd);
	newfd = dup2(outfd, 1);
	YDB_ASSERT(1 == newfd);
	sprintf(errfile, "simpleapi_threeen1f.mje%d", childnum);
	errfd = creat(errfile, 0666);
	YDB_ASSERT(-1 != errfd);
	newfd = dup2(errfd, 2);
	YDB_ASSERT(2 == newfd);

	/* Start with zero reads, writes and highest number */
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ylcl_reads, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_s(&ylcl_updates, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_s(&ylcl_highest, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	/* No need to invoke "digitsinit()" as child process inherits all local variables of parent */

	/* Get lock l2 that parent will wait on till this Jobbed processes is done */
	YDB_COPY_BUFF_TO_BUFF(&pidvalue, &subscr[0]);	/* copy over "$j" into 1st subscript */
	status = ydb_lock_incr_s(LOCK_TIMEOUT, &ylcl_l2, 1, subscr);
	YDB_ASSERT(YDB_OK == status);

	/* Decrement ^count to say this process is alive */
	tmpvalue.len_used = sprintf(tmpvalue.buf_addr, "%d", -1);
	status = ydb_incr_s(&ygbl_count, 0, NULL, &tmpvalue, &value);
	YDB_ASSERT(YDB_OK == status);

	/* This process will get lock l1($JOB) only after parent has released lock on l1 */
	status = ydb_lock_incr_s(LOCK_TIMEOUT, &ylcl_l1, 1, subscr);
	YDB_ASSERT(YDB_OK == status);

	/* Process the next block in ^limits that needs processing; quit when done */
	tmp = 0;
	for ( ; ; )
	{
		tmp++;
		subscr[0].len_used = sprintf(subscr[0].buf_addr, "%d", tmp);
		status = ydb_data_s(&ygbl_limits, 1, subscr, &data_value);
		YDB_ASSERT(YDB_OK == status);
		if (0 == data_value)
			break;

		subscr[1].len_used = sprintf(subscr[1].buf_addr, "%d", 1);
		status = ydb_incr_s(&ygbl_limits, 2, subscr, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		cnt = atoi(value.buf_addr);
		if (1 != cnt)
			continue;

		subscr[0].len_used = sprintf(subscr[0].buf_addr, "%d", tmp - 1);
		status = ydb_get_s(&ygbl_limits, 1, subscr, &value);
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
		status = ydb_get_s(&ygbl_limits, 1, subscr, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		cnt = atoi(value.buf_addr);
		last = cnt;
		dostep(first, last);
	}
	/* Update global statistics inside a transaction */
	tpfn = &tp_gvstatsincr;
	status = ydb_tp_s(tpfn, NULL, NULL, 0, NULL);
	YDB_ASSERT(YDB_OK == status);

	/* Release locks to tell parent this parent is done */
	YDB_COPY_BUFF_TO_BUFF(&pidvalue, &subscr[0]);	/* copy over "$j" into 1st subscript */
	status = ydb_lock_decr_s(&ylcl_l1, 1, subscr);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_lock_decr_s(&ylcl_l2, 1, subscr);
	YDB_ASSERT(YDB_OK == status);
	return;
}

/* The following function unconditionally adds the number of reads & write performed by this process to the
 * number of reads & writes performed by all processes, and sets the highest for all processes if the
 * highest calculated by this process is greater than that calculated so far for all processes
 */
int tp_gvstatsincr(void *v)
{
	int	highest_gbl, highest_lcl;
	int	status;

	status = ydb_incr_s(&ygbl_reads, 0, NULL, &ylcl_reads, &value);
	if (YDB_TP_RESTART == status)
		return status;
	YDB_ASSERT(YDB_OK == status);

	status = ydb_incr_s(&ygbl_updates, 0, NULL, &ylcl_updates, &value);
	if (YDB_TP_RESTART == status)
		return status;
	YDB_ASSERT(YDB_OK == status);

	status = ydb_get_s(&ygbl_highest, 0, NULL, &value);
	if (YDB_TP_RESTART == status)
		return status;
	if (YDB_ERR_GVUNDEF != status)
	{
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		highest_gbl = atoi(value.buf_addr);
	} else
		highest_gbl = 0;
	status = ydb_get_s(&ylcl_highest, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	highest_lcl = atoi(value.buf_addr);
	if (highest_lcl > highest_gbl)
	{
		status = ydb_set_s(&ygbl_highest, 0, NULL, &value);
		if (YDB_TP_RESTART == status)
			return status;
		YDB_ASSERT(YDB_OK == status);
	}
	return YDB_OK;
}

/* Implements M entryref dostep^threeen1f */
void	dostep(int first, int last)
{
	long long	current, i;
	long long	tmp1, tmp2;
	int		status;
	long long	highest_lcl;
	unsigned int	data_value;
	long long	n;
	ydb_buffer_t	*tmpbuff;
	ydb_tpfnptr_t	tpfn;

	for (current = first; current <= last; current++)
	{
		n = current;

		/* Currpath holds path to 1 for current */
		status = ydb_delete_s(&ylcl_currpath, 0, NULL, YDB_DEL_TREE);
		YDB_ASSERT(YDB_OK == status);

		/* Go till we reach 1 or a number with a known number of steps */
		for (i = 0; ; i++)
		{
			status = ydb_incr_s(&ylcl_reads, 0, NULL, NULL, &value);
			YDB_ASSERT(YDB_OK == status);

			if (1 == n)
				break;

			inttostr(n, &subscr[0]);
			status = ydb_data_s(&ygbl_step, 1, subscr, &data_value);
			YDB_ASSERT(YDB_OK == status);
			if (data_value)
				break;

			/* log n as current number in sequence */
			value.len_used = sprintf(value.buf_addr, "%lld", n);
			subscr[0].len_used = sprintf(subscr[0].buf_addr, "%lld", i);
			status = ydb_set_s(&ylcl_currpath, 1, subscr, &value);
			YDB_ASSERT(YDB_OK == status);

			/* compute the next number */
			if (0 == (n % 2))
				n = n / 2;
			else
				n = (3 * n) + 1;

			/* see if we have a new highest number reached */
			status = ydb_get_s(&ylcl_highest, 0, NULL, &tmpvalue);
			YDB_ASSERT(YDB_OK == status);
			tmpvalue.buf_addr[tmpvalue.len_used] = '\0';
			highest_lcl = atoll(tmpvalue.buf_addr);
			if (n > highest_lcl)
			{
				status = ydb_set_s(&ylcl_highest, 0, NULL, &value);
				YDB_ASSERT(YDB_OK == status);
			}
		}
		/* if 0 == i we already have an answer for n, nothing to do here */
		if (0 < i)
		{
			if (1 < n)
			{
				inttostr(n, &subscr[0]);
				status = ydb_get_s(&ygbl_step, 1, subscr, &value);
				YDB_ASSERT(YDB_OK == status);
				i = i + strtoint(&value);
			}
			/* Atomically set maximum */
			tpfn = &tp_setmaximum;
			status = ydb_tp_s(tpfn, &i, NULL, 0, NULL);
			YDB_ASSERT(YDB_OK == status);
			subscr[0].len_used = 0;	/* to start $order */
			for ( ; ; )
			{
				status = ydb_subscript_next_s(&ylcl_currpath, 1, subscr, &value);
				YDB_ASSERT(YDB_OK == status);
				if (0 == value.len_used)
					break;
				value.buf_addr[value.len_used] = '\0';
				tmp1 = atoi(value.buf_addr);
				YDB_COPY_BUFF_TO_BUFF(&value, &subscr[0]);	/* take a copy before it changes */
				status = ydb_incr_s(&ylcl_updates, 0, NULL, NULL, &value);
				YDB_ASSERT(YDB_OK == status);

				status = ydb_get_s(&ylcl_currpath, 1, subscr, &value);
				YDB_ASSERT(YDB_OK == status);
				value.buf_addr[value.len_used] = '\0';
				tmp2 = atoll(value.buf_addr);
				inttostr(tmp2, &subscr[0]);
				inttostr(i - tmp1, &value);
				status = ydb_set_s(&ygbl_step, 1, subscr, &value);
				YDB_ASSERT(YDB_OK == status);
				subscr[0].len_used = sprintf(subscr[0].buf_addr, "%lld", tmp1);
			}
		}
	}
}

int tp_setmaximum(long long *i)
{
	int	result;
	int	status;

	status = ydb_get_s(&ygbl_result, 0, NULL, &value);
	if (YDB_TP_RESTART == status)
		return status;
	if (YDB_ERR_GVUNDEF != status)
	{
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		result = atoi(value.buf_addr);
	} else
		result = 0;
	if (*i > result)
	{
		value.len_used = sprintf(value.buf_addr, "%lld", *i);
		status = ydb_set_s(&ygbl_result, 0, NULL, &value);
		if (YDB_TP_RESTART == status)
			return status;
		YDB_ASSERT(YDB_OK == status);
	}
	return YDB_OK;
}
