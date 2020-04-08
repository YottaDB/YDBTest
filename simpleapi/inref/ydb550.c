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
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>
#include "libyottadb.h"

#define USER_SPECIFIC_STATUS_CODE	100

#define PRINT_PROC_ID(PID)		\
{						\
	printf("Process P%d:", PID);	\
}

int callback1();
int callback2();
int callback1_us();
int callback2_us();
int callback1_common(ydb_buffer_t *varname, int is_user_specific, int pid, int *printed_through);
int callback2_common(ydb_buffer_t *varname, int pid, int *printed_through);
void check_updates(ydb_buffer_t varname);

struct transargs
{
	ydb_buffer_t	*varname;
	int		pid, *printed_through;
};

int main()
{
	ydb_tpfnptr_t		cb;
	int			status, i, printed_through;
	ydb_buffer_t		varname;
	pid_t			is_parent;
	struct transargs	args;

	cb = &callback1;
	is_parent = fork();
	YDB_ASSERT(is_parent != -1); // make sure fork succeeded
	varname.len_alloc = varname.len_used = 5;
	if (is_parent)
	{
		varname.buf_addr = "^UPD1";
		args.pid = 1;
	}
	else
	{
		varname.buf_addr = "^UPD2";
		args.pid = 2;
	}
	args.varname = &varname;
	printed_through = 0;
	args.printed_through = &printed_through;
	PRINT_PROC_ID(args.pid);
	printf("Test 1 : Test YDB_TP_ROLLBACK handling\n");
	PRINT_PROC_ID(args.pid);
	printf("a)	The flow is : CPROGRAM -> ydb_tp_s()1 -> CALLBACK1 -> ydb_tp_s()2 -> CALLBACK2. Here CPROGRAM is the ");
	printf("C program which invokes ydb_tp_s(). CALLBACK1 is the user-specified TP callback");
	printf(" function at TP depth 1 and CALLBACK2 is the user-specified TP callback function at TP depth 2.\n");
	do
		status = ydb_tp_s(cb, &args, NULL, 0, NULL);
	while (YDB_OK != status);
	YDB_ASSERT(YDB_OK == status);
	PRINT_PROC_ID(args.pid);
	printf("ydb_tp_s()1 returned YDB_OK as expected\n");
	PRINT_PROC_ID(args.pid);
	printf("Since control has returned from ydb_tp_s()1 CPROGRAM will check that the first and third updates exist ");
	printf("in the db but the second update doesn't.\n");
	check_updates(varname);

	printf("\n");
	PRINT_PROC_ID(args.pid);
	printf("Test 2 : Test user-specific-error-code handling\n");
	if (is_parent)
		varname.buf_addr = "^USD1";
	else
		varname.buf_addr = "^USD2";
	printed_through = 0;
	args.varname = &varname;
	cb = &callback1_us;
	PRINT_PROC_ID(args.pid);
	printf("Flow is very similar to Test 1 but instead of returning YDB_TP_ROLLBACK, CALLBACK2 returns a ");
	printf("user-specific status code (USER_SPECIFIC_STATUS_CODE).\n");
	status = ydb_tp_s(cb, &args, NULL, 0, NULL);
	YDB_ASSERT(YDB_OK == status);
	PRINT_PROC_ID(args.pid);
	printf("ydb_tp_s()1 returned YDB_OK as expected\n");
	PRINT_PROC_ID(args.pid);
	printf("Since control has returned from ydb_tp_s()1 CPROGRAM will check that the first and third updates ");
	printf("exist in the db but the second update doesn't.\n");
	check_updates(varname);

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

int callback1_common(ydb_buffer_t *varname, int is_user_specific, int pid, int *printed_through)
{
	ydb_tpfnptr_t		cb2;
	int			status;
	char			errbuf[2048];
	ydb_buffer_t		subscript, value;
	struct transargs	args;

	if (is_user_specific)
		cb2 = &callback2_us;
	else
		cb2 = &callback2;
	args.varname = varname;
	args.pid = pid;
	args.printed_through = printed_through;
	if (1 > *printed_through)
	{
		PRINT_PROC_ID(pid);
		printf("CALLBACK1 will do some db updates using ydb_set_s() before calling ydb_tp_s()2 (first set of updates) ");
		printf("which calls CALLBACK2.\n");
		*printed_through = 1;
	}
	subscript.len_alloc = subscript.len_used = 1;
	subscript.buf_addr = "1";
	value.len_alloc = value.len_used = 3;
	value.buf_addr = "set";
	status = ydb_set_s(varname, 1, &subscript, &value);
	if (YDB_OK != status)
		return status;
	YDB_ASSERT(YDB_OK == status);
	status = ydb_tp_s(cb2, &args, NULL, 0, NULL);
	if (YDB_TP_RESTART == status)
		return status;
	if (4 > *printed_through)
		PRINT_PROC_ID(pid);
	if (is_user_specific)
	{
		if (4 > *printed_through)
			printf("CALLBACK1 will check that the return from ydb_tp_s()2 is actually USER_SPECIFIC_STATUS_CODE.\n");
		YDB_ASSERT(USER_SPECIFIC_STATUS_CODE == status);
	} else
	{
		if (4 > *printed_through)
			printf("CALLBACK1 will check that the return from ydb_tp_s()2 is actually YDB_TP_ROLLBACK.\n");
		YDB_ASSERT(YDB_TP_ROLLBACK == status);
	}
	if (4 > *printed_through)
	{
		PRINT_PROC_ID(pid);
		printf("Since control has returned from ydb_tp_s()2, CALLBACK1 will do some more updates (third set of updates) ");
		printf("using ydb_set_s() then return YDB_OK.\n");
		*printed_through = 4;
	}
	subscript.buf_addr = "3";
	status = ydb_set_s(varname, 1, &subscript, &value);
	if (YDB_OK != status)
		return status;
	YDB_ASSERT(YDB_OK == status);

	return YDB_OK;
}

int callback2_common(ydb_buffer_t *varname, int pid, int *printed_through)
{
	int		status;
	ydb_buffer_t	subscript, value;

	subscript.len_alloc = subscript.len_used = 1;
	subscript.buf_addr = "2";
	value.len_alloc = value.len_used = 3;
	value.buf_addr = "set";
	if (2 > *printed_through)
	{
		PRINT_PROC_ID(pid);
		printf("CALLBACK2 will do some db updates (second set of updates) using ydb_set_s()\n");
		*printed_through = 2;
	}
	status = ydb_set_s(varname, 1, &subscript, &value);
	return status;
}

int callback1(struct transargs *args)
{
	ydb_buffer_t	*varname;
	int		pid, *printed_through;

	varname = args->varname;
	pid = args->pid;
	printed_through = args->printed_through;
	return callback1_common(varname, 0, pid, printed_through);
}

int callback2(struct transargs *args)
{
	ydb_buffer_t	*varname;
	int		status, pid, *printed_through;

	varname = args->varname;
	pid = args->pid;
	printed_through = args->printed_through;
	status = callback2_common(varname, pid, printed_through);
	if (YDB_TP_RESTART == status)
		return status;
	if (3 > *printed_through)
	{
		PRINT_PROC_ID(pid);
		printf("CALLBACK2 will return YDB_TP_ROLLBACK\n");
		*printed_through = 3;
	}
	return YDB_TP_ROLLBACK;
}

int callback1_us(struct transargs *args)
{
	ydb_buffer_t	*varname;
	int		pid, *printed_through;

	varname = args->varname;
	pid = args->pid;
	printed_through = args->printed_through;
	return callback1_common(varname, 1, pid, printed_through);
}

int callback2_us(struct transargs *args)
{
	ydb_buffer_t	*varname;
	int		status, pid, *printed_through;

	varname = args->varname;
	pid = args->pid;
	printed_through = args->printed_through;
	status = callback2_common(varname, pid, printed_through);
	if (YDB_TP_RESTART == status)
		return status;
	if (3 > *printed_through)
	{
		PRINT_PROC_ID(pid);
		printf("CALLBACK2 will return USER_SPECIFIC_STATUS_CODE\n");
		*printed_through = 3;
	}
	return USER_SPECIFIC_STATUS_CODE;
}

void check_updates(ydb_buffer_t varname)
{
	int		status;
	ydb_buffer_t	subscript, value;

	subscript.len_alloc = subscript.len_used = 1;
	subscript.buf_addr = "1";
	value.len_alloc = 3;
	value.len_used = 0;
	value.buf_addr = (char *)malloc(3);
	status = ydb_get_s(&varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_OK == status)
	subscript.buf_addr = "2";
	status = ydb_get_s(&varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_ERR_GVUNDEF == status)
	subscript.buf_addr = "3";
	status = ydb_get_s(&varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_OK == status);
	free(value.buf_addr);
}
