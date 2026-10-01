/****************************************************************
 *								*
 * Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* Usage: ydb1291_fork <msec>
 *
 * Update ^x (region DEFAULT), wait 500 milliseconds, update ^a (region AREG), then fork <msec> milliseconds after
 * the ^x update. With a flush time of 1 second, the flush timer for DEFAULT comes due at about 1000 milliseconds
 * and the one for AREG at about 1500 milliseconds.
 *
 * A pthread_atfork() prepare handler registered before the first YottaDB call runs AFTER the YottaDB prepare handler
 * (prepare handlers run in the reverse order of registration). It busy-waits until <msec>, so the SIGALRM for the
 * DEFAULT flush timer arrives after YottaDB has handled any deferred timers. The flush timer handler cannot run inside
 * the signal handler, so the parent defers it and the child inherits the deferred timer and the still pending AREG timer.
 *
 * The child then reads ^x, which must work.
 */

#include "libyottadb.h"

#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

static struct timespec	t0;
static long		fork_at_msec;

static long msec_since_t0(void)
{
	struct timespec	now;

	clock_gettime(CLOCK_MONOTONIC, &now);
	return (now.tv_sec - t0.tv_sec) * 1000 + (now.tv_nsec - t0.tv_nsec) / 1000000;
}

static void spin_prepare(void)
{
	if (fork_at_msec)
		while (msec_since_t0() < fork_at_msec)
			;
}

static int set_gvn(char *name)
{
	ydb_buffer_t	gvn, value;

	YDB_STRING_TO_BUFFER(name, &gvn);
	YDB_LITERAL_TO_BUFFER("1", &value);
	return ydb_set_s(&gvn, 0, NULL, &value);
}

int main(int argc, char *argv[])
{
	ydb_buffer_t	gvn, value;
	char		valbuff[64], errbuff[1024];
	int		status, wstatus;
	pid_t		pid, ret;
	struct timespec	halfsec = {0, 500000000};

	if (2 != argc)
	{
		printf("WRONG : usage: %s <msec>\n", argv[0]);
		return 1;
	}
	pthread_atfork(spin_prepare, NULL, NULL);
	status = set_gvn("^x");
	clock_gettime(CLOCK_MONOTONIC, &t0);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuff, sizeof(errbuff));
		printf("WRONG : parent ydb_set_s(^x) returned %d : %s\n", status, errbuff);
		return 1;
	}
	nanosleep(&halfsec, NULL);
	status = set_gvn("^a");
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuff, sizeof(errbuff));
		printf("WRONG : parent ydb_set_s(^a) returned %d : %s\n", status, errbuff);
		return 1;
	}
	fflush(stdout);
	fork_at_msec = atol(argv[1]);
	pid = fork();
	if (-1 == pid)
	{
		perror("WRONG : fork()");
		return 1;
	}
	if (0 == pid)
	{
		YDB_LITERAL_TO_BUFFER("^x", &gvn);
		value.buf_addr = valbuff;
		value.len_alloc = sizeof(valbuff);
		value.len_used = 0;
		status = ydb_get_s(&gvn, 0, NULL, &value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuff, sizeof(errbuff));
			printf("WRONG : child ydb_get_s(^x) returned %d : %s, expected YDB_OK\n", status, errbuff);
		} else if ((1 != value.len_used) || ('1' != value.buf_addr[0]))
			printf("WRONG : child ydb_get_s(^x) returned [%.*s], expected [1]\n", value.len_used, value.buf_addr);
		else
			printf("PASS : child ydb_get_s(^x) returned YDB_OK and [1]\n");
		fflush(stdout);
		return 0;
	}
	/* The parent's own flush timers can interrupt the wait */
	do
		ret = waitpid(pid, &wstatus, 0);
	while ((-1 == ret) && (EINTR == errno));
	if (-1 == ret)
		perror("WRONG : waitpid()");
	else if (!WIFEXITED(wstatus))
		printf("WRONG : child was killed by signal %d, expected it to exit with status 0\n", WTERMSIG(wstatus));
	else if (0 != WEXITSTATUS(wstatus))
		printf("WRONG : child exited with status %d, expected 0\n", WEXITSTATUS(wstatus));
	else
		printf("PASS : child exited with status 0\n");
	return 0;
}
