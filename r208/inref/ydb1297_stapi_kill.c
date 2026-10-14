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

/* A SimpleThreadAPI program whose main thread makes no YottaDB call and spends nearly all its time inside
 * malloc() and free(), so that a signal sent to the process with kill() usually arrives in the main thread
 * while it is inside malloc(). A worker thread makes the YottaDB calls.
 *
 * argv[1] = "busy" : the worker loops on ydb_set_st(), so a thread usually holds the YottaDB engine lock
 * argv[1] = "idle" : the worker makes one ydb_set_st() call and then waits, so no thread holds the engine lock
 *
 * The program prints "ready" once the worker's first ydb_set_st() call has returned, and then runs until it is
 * killed. The sizes allocated are above the glibc tcache limit (1032 bytes), so each malloc() and free() takes
 * the malloc() arena lock.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <unistd.h>

#include "libyottadb.h"

#define	NUM_PTRS	64
#define	MIN_SIZE	2048
#define	SIZE_RANGE	(96 * 1024)

static int		idle_worker;
static volatile int	worker_ready;

static void *worker(void *arg)
{
	ydb_buffer_t	var, val;
	char		buf[32];
	unsigned long	i;
	int		status;

	YDB_LITERAL_TO_BUFFER("x", &var);
	for (i = 0; ; i++)
	{
		snprintf(buf, sizeof(buf), "%lu", i);
		val.buf_addr = buf;
		val.len_used = val.len_alloc = strlen(buf);
		status = ydb_set_st(YDB_NOTTP, NULL, &var, 0, NULL, &val);
		if (YDB_OK != status)
		{
			printf("WRONG : ydb_set_st() returned %d\n", status);
			fflush(stdout);
			exit(1);
		}
		worker_ready = 1;
		if (idle_worker)
			for ( ; ; )
				pause();
	}
	return NULL;
}

int main(int argc, char **argv)
{
	pthread_t	thread;
	void		*ptrs[NUM_PTRS];
	unsigned int	seed = 1;
	int		i;

	if ((2 != argc) || ((0 != strcmp(argv[1], "busy")) && (0 != strcmp(argv[1], "idle"))))
	{
		printf("Usage : %s busy|idle\n", argv[0]);
		return 1;
	}
	idle_worker = (0 == strcmp(argv[1], "idle"));
	memset(ptrs, 0, sizeof(ptrs));
	if (0 != pthread_create(&thread, NULL, worker, NULL))
	{
		printf("WRONG : pthread_create() failed\n");
		return 1;
	}
	while (!worker_ready)
		usleep(1000);
	printf("ready\n");
	fflush(stdout);
	for ( ; ; )
	{
		i = rand_r(&seed) % NUM_PTRS;
		free(ptrs[i]);
		ptrs[i] = malloc(MIN_SIZE + (rand_r(&seed) % SIZE_RANGE));
	}
	return 0;
}
