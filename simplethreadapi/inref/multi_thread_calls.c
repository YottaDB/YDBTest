/****************************************************************
 *								*
 * Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>
#include <pthread.h>
#include "libyottadb.h"

/* This program is a simplified version of "simplethreadapi/inref/ydb550.c" focused on doing "ydb_tp_st()"
 * calls from multiple threads at the same time.
 */
#define	NUM_THREADS	100

int callback1();
void* start_thread(void *args);
pthread_t tids[NUM_THREADS];

int main()
{
	int	status, i;

	for (i = 0; i < NUM_THREADS; i++)
	{
		status = pthread_create(&tids[i], NULL, &start_thread, NULL);
		YDB_ASSERT(0 == status);
	}
	for (i = 0; i < NUM_THREADS; i++)
	{
		status = pthread_join(tids[i], NULL);
		YDB_ASSERT(0 == status);
	}
	return 0;
}

void* start_thread(void *args)
{
	ydb_tp2fnptr_t	cb;
	int		status;

	cb = &callback1;
	status = ydb_tp_st(YDB_NOTTP, NULL, cb, NULL, NULL, 0, NULL);
	YDB_ASSERT(YDB_OK == status);
}

int callback1(uint64_t tptoken, ydb_buffer_t* errstr, void *args)
{
	return YDB_OK;
}

