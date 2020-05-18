/****************************************************************
 *								*
 * Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>
#include "libyottadb.h"

#define ONESEC		((unsigned long long)1000000000)

struct threadargs
{
	int	pid, tid;
};

struct transargs
{
	ydb_buffer_t	*varname;
	int		tid, ok_iteration, total_iteration, pid;
};

int callback1();
int callback2();
void check_updates(struct transargs *args);
void* start_thread(void *args);
void timer_done(intptr_t timer_id, unsigned int handler_data_len, char *handler_data);
pthread_t tids[4];

int is_done[4];

int main()
{
	int			status, i, is_parent, pid;
	struct threadargs	args[4];

	for(int i = 0; i < 3; i++)
	{
		is_parent = fork();
		if(!is_parent)
		{
			pid = i + 2;
			break;
		}
	}
	if (is_parent)
		pid = 1;
	args[0].tid = 1;
	args[1].tid = 2;
	args[2].tid = 3;
	args[3].tid = 4;
	for (i = 0; i < 4; i++)
	{
		is_done[i] = 0;
		args[i].pid = pid;
		status = pthread_create(&tids[i], NULL, &start_thread, &args[i]);
		YDB_ASSERT(0 == status);
	}
	for (i = 0; i < 4; i++)
	{
		status = pthread_join(tids[i], NULL);
		YDB_ASSERT(0 == status);
	}

	if (is_parent) {
		/* The below code to wait for child processes
		 * was copied from simpleapi/inref/randomWalk.c
		 */
		/* wait for all child processes to die
		 * have to check for EINTR from yottadb
		 * other wise the parent will exit early
		 */
		while (1)
		{
			if (-1 == (i = wait(&status)))
			{
				if (EINTR == errno)
					continue;
				break;
			}
		}
	}
	return 0;
}

void* start_thread(void *args)
{
	ydb_tp2fnptr_t		cb;
	int			status, *tid, timer_id, stime;
	unsigned long long	timer_length;
	ydb_buffer_t		varname;
	struct threadargs	*vars;
	struct transargs	targs;

	vars = (struct threadargs*) args;
	targs.tid = vars->tid;
	targs.pid = vars->pid;
	timer_id = (targs.tid) - 1;
	timer_length = 10 * ONESEC;
	stime = time(NULL);
	status = ydb_timer_start_t(YDB_NOTTP, NULL, timer_id, timer_length, &timer_done, 1, &stime);
	YDB_ASSERT(YDB_OK == status);
	varname.len_alloc = varname.len_used = 8;
	varname.buf_addr = "^VARNAME";
	targs.varname = &varname;
	targs.ok_iteration = 1;
	targs.total_iteration = 1;
	cb = &callback1;

	while(!is_done[timer_id])
	{
		status = ydb_tp_st(YDB_NOTTP, NULL, cb, &targs, NULL, 0, NULL);
		YDB_ASSERT(YDB_OK == status);
		targs.ok_iteration++;
		check_updates(&targs);
	}
	/* Make sure some YDB_TP_RESTARTs were generated during the loop */
	YDB_ASSERT(targs.ok_iteration < targs.total_iteration);
}

int callback1(uint64_t tptoken, ydb_buffer_t* errstr, struct transargs *args)
{
	ydb_tp2fnptr_t		cb2;
	ydb_buffer_t		*varname;
	char			temp_sub[3], temp_val[1];
	int			status;
	ydb_buffer_t		subscript, value;

	args->total_iteration++;
	cb2 = &callback2;
	subscript.len_alloc = subscript.len_used = 3;
	temp_sub[0] = (char)('0' + args->pid);
	temp_sub[1] = (char)('0' + args->tid);
	temp_sub[2] = '1';
	subscript.buf_addr = temp_sub;
	value.len_alloc = value.len_used = 1;
	temp_val[0] = 'a';
	value.buf_addr = temp_val;
	temp_val[0] = temp_val[0] + (args->ok_iteration % 26);
	status = ydb_set_st(tptoken, errstr, args->varname, 1, &subscript, &value);
	if (YDB_OK != status)
		return status;
	YDB_ASSERT(YDB_OK == status);
	status = ydb_tp_st(tptoken, errstr, cb2, args, NULL, 0, NULL);
	if (YDB_TP_RESTART == status)
		return status;
	YDB_ASSERT(YDB_TP_ROLLBACK == status);
	temp_sub[2] = '3';
	status = ydb_set_st(tptoken, errstr, args->varname, 1, &subscript, &value);
	if (YDB_OK != status)
		return status;
	YDB_ASSERT(YDB_OK == status);

	return YDB_OK;
}

int callback2(uint64_t tptoken, ydb_buffer_t* errstr, struct transargs *args)
{
	int		status;
	char		temp_sub[3], temp_val[1];
	ydb_buffer_t	subscript, value;

	subscript.len_alloc = subscript.len_used = 3;
	temp_sub[0] = (char)('0' + args->pid);
	temp_sub[1] = (char)('0' + args->tid);
	temp_sub[2] = '2';
	subscript.buf_addr = temp_sub;
	value.len_alloc = value.len_used = 1;
	temp_val[0] = (char)('a' + (args->ok_iteration % 26));
	value.buf_addr = temp_val;
	status = ydb_set_st(tptoken, errstr, args->varname, 1, &subscript, &value);
	return YDB_TP_RESTART == status ? status : YDB_TP_ROLLBACK;
}

void check_updates(struct transargs *args)
{
	int		status;
	char		temp_sub[3];
	ydb_buffer_t	subscript, value;

	subscript.len_alloc = subscript.len_used = 3;
	temp_sub[0] = (char)('0' + args->pid);
	temp_sub[1] = (char)('0' + args->tid);
	temp_sub[2] = '1';
	subscript.buf_addr = temp_sub;
	value.len_alloc = 1;
	value.len_used = 0;
	value.buf_addr = (char *)malloc(1);
	status = ydb_get_st(YDB_NOTTP, NULL, args->varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_OK == status);
	YDB_ASSERT((char)('a' + ((args->ok_iteration - 1) % 26)) == value.buf_addr[0]);
	temp_sub[2] = '2';
	status = ydb_get_st(YDB_NOTTP, NULL, args->varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_ERR_GVUNDEF == status);
	temp_sub[2] = '3';
	status = ydb_get_st(YDB_NOTTP, NULL, args->varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_OK == status);
	YDB_ASSERT((char)('a' + ((args->ok_iteration - 1) % 26)) == value.buf_addr[0]);
	free(value.buf_addr);
}

void timer_done(intptr_t timer_id, unsigned int handler_data_len, char *handler_data)
{
	is_done[timer_id] = 1;
}
