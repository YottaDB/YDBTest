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
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>
#include "libyottadb.h"

#define ONESEC		((unsigned long long)1000000000)

struct transargs
{
	ydb_buffer_t	*varname;
	int		pid, ok_iteration, total_iteration;
};

int callback1();
int callback2();
void check_updates(struct transargs *args);
void timer_done(intptr_t timer_id, unsigned int handler_data_len, char *handler_data);

int is_done;

int main()
{
	ydb_tpfnptr_t		cb;
	int			status, i, pid, stime, timer_id;
	unsigned long long	timer_length;
	ydb_buffer_t		varname;
	pid_t			is_parent;
	struct transargs	args;

	cb = &callback1;
	varname.len_alloc = varname.len_used = 8;
	varname.buf_addr = "^VARNAME";
	is_parent = fork();
	YDB_ASSERT(is_parent != -1); // make sure fork succeeded
	if (is_parent)
		pid = 1;
	else
		pid = 2;
	is_parent = fork();
	YDB_ASSERT(is_parent != -1); // make sure fork succeeded
	if (!is_parent)
		pid = pid + 2;
	args.varname = &varname;
	args.pid = pid;
	args.ok_iteration = 1;
	args.total_iteration = 1;

	is_done = 0;
	timer_id = 0;
	timer_length = 10 * ONESEC;
	stime = time(NULL);
	status = ydb_timer_start(timer_id, timer_length, &timer_done, sizeof(&stime), &stime);
	if (YDB_OK != status)
	{
		printf("ydb_timer_start() did not return the correct status. Got: %d; Expected: %d\n", status, YDB_OK);
		YDB_ASSERT(FALSE);
	}

	while (!is_done)
	{
		status = ydb_tp_s(cb, &args, NULL, 0, NULL);
		YDB_ASSERT(YDB_OK == status)
		args.ok_iteration++;
		check_updates(&args);
	}
	/* Make sure some YDB_TP_RESTARTs were generated during the loop
	 * This check is disabled on 1-CPU machines because they might not
	 * produce any YDB_TP_RESTARTs within the 10 second time limit.
	 */
	if (((int)sysconf(_SC_NPROCESSORS_ONLN)) > 1)
		YDB_ASSERT(args.ok_iteration < args.total_iteration);

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

	return 0;
}

int callback1(struct transargs *args)
{
	ydb_tpfnptr_t		cb2;
	int			status;
	char			temp_sub[2], temp_val[1];
	ydb_buffer_t		subscript, value;

	args->total_iteration++;
	cb2 = &callback2;
	subscript.len_alloc = subscript.len_used = 2;
	temp_sub[0] = (char)('0' + args->pid);
	temp_sub[1] = '1';
	subscript.buf_addr = temp_sub;
	value.len_alloc = value.len_used = 1;
	temp_val[0] = 'a';
	value.buf_addr = temp_val;
	temp_val[0] = temp_val[0] + (args->ok_iteration % 26);
	status = ydb_set_s(args->varname, 1, &subscript, &value);
	if (YDB_OK != status)
		return status;
	YDB_ASSERT(YDB_OK == status);
	status = ydb_tp_s(cb2, args, NULL, 0, NULL);
	if (YDB_TP_RESTART == status)
		return status;
	YDB_ASSERT(YDB_TP_ROLLBACK == status)
	temp_sub[1] = '3';
	status = ydb_set_s(args->varname, 1, &subscript, &value);
	if(YDB_OK != status)
		return status;
	YDB_ASSERT(YDB_OK == status);

	return YDB_OK;
}

int callback2(struct transargs *args)
{
	int		status;
	char		temp_sub[2], temp_val[1];
	ydb_buffer_t	subscript, value;

	subscript.len_alloc = subscript.len_used = 2;
	temp_sub[0] = (char)('0' + args->pid);
	temp_sub[1] = '2';
	subscript.buf_addr = temp_sub;
	value.len_alloc = value.len_used = 1;
	temp_val[0] = (char)('a' + (args->ok_iteration % 26));
	value.buf_addr = temp_val;
	status = ydb_set_s(args->varname, 1, &subscript, &value);
	return YDB_TP_RESTART == status ? status : YDB_TP_ROLLBACK;
}

void check_updates(struct transargs *args)
{
	int		status;
	char		temp_sub[2];
	ydb_buffer_t	subscript, value;

	subscript.len_alloc = subscript.len_used = 2;
	temp_sub[0] = (char)('0' + args->pid);
	temp_sub[1] = '1';
	subscript.buf_addr = temp_sub;
	value.len_alloc = 1;
	value.len_used = 0;
	value.buf_addr = (char *)malloc(1);
	status = ydb_get_s(args->varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_OK == status)
	YDB_ASSERT((char)('a' + ((args->ok_iteration - 1) % 26)) == value.buf_addr[0])
	temp_sub[1] = '2';
	status = ydb_get_s(args->varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_ERR_GVUNDEF == status)
	temp_sub[1] = '3';
	status = ydb_get_s(args->varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_OK == status);
	YDB_ASSERT((char)('a' + ((args->ok_iteration - 1) % 26)) == value.buf_addr[0])
	free(value.buf_addr);
}

void timer_done(intptr_t timer_id, unsigned int handler_data_len, char *handler_data)
{
	is_done = 1;
}
