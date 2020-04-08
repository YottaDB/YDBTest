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
#include <pthread.h>
#include "libyottadb.h"

#define USER_SPECIFIC_STATUS_CODE	100

#define PRINT_THREAD_ID(FILE, TID)		\
{						\
	fprintf(FILE, "Thread T%d:", TID);	\
}

int callback1();
int callback2();
int callback1_us();
int callback2_us();
int callback1_common(uint64_t tptoken, ydb_buffer_t* errstr, ydb_buffer_t *varname, int is_user_specific, FILE* file, int tid,
		int *printed_through);
int callback2_common(uint64_t tptoken, ydb_buffer_t* errstr, ydb_buffer_t *varname, FILE* file, int tid, int *printed_through);
void check_updates(ydb_buffer_t varname);
void* start_thread(void *args);
pthread_t tids[4];



struct threadargs
{
	ydb_buffer_t	varname1;
	ydb_buffer_t	varname2;
	FILE 		*file;
	int		tid;
};

struct transargs
{
	ydb_buffer_t	*varname;
	FILE		*file;
	int		tid;
	int		*printed_through;
};

int main()
{
	int			status, i;
	struct threadargs	args[4];

	args[0].varname1.buf_addr = "^UPD1";
	args[0].varname2.buf_addr = "^USD1";
	args[0].file = fopen("thread1.out", "w");
	args[0].tid = 1;
	args[1].varname1.buf_addr = "^UPD2";
	args[1].varname2.buf_addr = "^USD2";
	args[1].file = fopen("thread2.out", "w");
	args[1].tid = 2;
	args[2].varname1.buf_addr = "^UPD3";
	args[2].varname2.buf_addr = "^USD3";
	args[2].file = fopen("thread3.out", "w");
	args[2].tid = 3;
	args[3].varname1.buf_addr = "^UPD4";
	args[3].varname2.buf_addr = "^USD4";
	args[3].file = fopen("thread4.out", "w");
	args[3].tid = 4;
	for (i = 0; i < 4; i++)
	{
		args[i].varname1.len_alloc = args[i].varname1.len_used = 5;
		args[i].varname2.len_alloc = args[i].varname2.len_used = 5;
		status = pthread_create(&tids[i], NULL, &start_thread, &args[i]);
		YDB_ASSERT(0 == status);
	}
	for (i = 0; i < 4; i++)
	{
		status = pthread_join(tids[i], NULL);
		YDB_ASSERT(0 == status);
	}
	fclose(args[0].file);
	fclose(args[1].file);
	fclose(args[2].file);
	fclose(args[3].file);
	return 0;
}

void* start_thread(void *args)
{
	ydb_tp2fnptr_t		cb;
	int			status, printed_through;
	struct threadargs	*vars;
	struct transargs	targs;

	vars = (struct threadargs*) args;
	targs.file = vars->file;
	targs.varname = &vars->varname1;
	targs.tid = vars->tid;
	printed_through = 0;
	targs.printed_through = &printed_through;
	cb = &callback1;

	PRINT_THREAD_ID(vars->file, vars->tid);
	fprintf(vars->file, "Test 1 : Test YDB_TP_ROLLBACK handling\n");
	PRINT_THREAD_ID(vars->file, vars->tid);
	fprintf(vars->file, "a)	The flow is : CPROGRAM -> ydb_tp_st()1 -> CALLBACK1 -> ydb_tp_st()2 -> CALLBACK2. ");
	fprintf(vars->file, "Here CPROGRAM is the C program which invokes ydb_tp_st(). CALLBACK1 is the ");
	fprintf(vars->file, "user-specified TP callback function at TP depth 1 and CALLBACK2 is the user-specified ");
	fprintf(vars->file, "TP callback function at TP depth 2.\n");
	do
		status = ydb_tp_st(YDB_NOTTP, NULL, cb, &targs, NULL, 0, NULL);
	while (YDB_OK != status);
	YDB_ASSERT(YDB_OK == status);
	PRINT_THREAD_ID(vars->file, vars->tid);
	fprintf(vars->file, "ydb_tp_st()1 returned YDB_OK as expected\n");
	PRINT_THREAD_ID(vars->file, vars->tid);
	fprintf(vars->file, "Since control has returned from ydb_tp_st()1 CPROGRAM will check that the ");
	fprintf(vars->file, "first and third updates exist in the db but the second update doesn't.\n");
	check_updates(vars->varname1);

	fprintf(vars->file, "\n");
	PRINT_THREAD_ID(vars->file, vars->tid);
	fprintf(vars->file, "Test 2 : Test user-specific-error-code handling\n");
	cb = &callback1_us;
	targs.varname = &vars->varname2;
	printed_through = 0;
	PRINT_THREAD_ID(vars->file, vars->tid);
	fprintf(vars->file, "Flow is very similar to Test 1 but instead of returning YDB_TP_ROLLBACK, CALLBACK2 returns ");
	fprintf(vars->file, "a user-specific status code (USER_SPECIFIC_STATUS_CODE).\n");
	status = ydb_tp_st(YDB_NOTTP, NULL, cb, &targs, NULL, 0, NULL);
	YDB_ASSERT(YDB_OK == status);
	PRINT_THREAD_ID(vars->file, vars->tid);
	fprintf(vars->file, "ydb_tp_st()1 returned YDB_OK as expected\n");
	PRINT_THREAD_ID(vars->file, vars->tid);
	fprintf(vars->file, "Since control has returned from ydb_tp_st()1 CPROGRAM will check that the ");
	fprintf(vars->file, "first and third updates exist in the db but the second update doesn't.\n");
	check_updates(vars->varname2);
}

int callback1_common(uint64_t tptoken, ydb_buffer_t* errstr, ydb_buffer_t *varname, int is_user_specific, FILE* file, int tid,
		int *printed_through)
{
	ydb_tp2fnptr_t		cb2;
	int			status;
	char			errbuf[2048];
	ydb_buffer_t		subscript, value;
	struct transargs	args;

	if (is_user_specific)
		cb2 = &callback2_us;
	else
		cb2 = &callback2;
	if (1 > *printed_through)
	{
		PRINT_THREAD_ID(file, tid);
		fprintf(file, "CALLBACK1 will do some db updates (first set of updates) using ydb_set_st() ");
		fprintf(file, "before calling ydb_tp_st()2 which calls CALLBACK2.\n");
		*printed_through = 1;
	}
	subscript.len_alloc = subscript.len_used = 1;
	subscript.buf_addr = "1";
	value.len_alloc = value.len_used = 3;
	value.buf_addr = "set";
	status = ydb_set_st(tptoken, errstr, varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_OK == status);
	args.varname = varname;
	args.file = file;
	args.tid = tid;
	args.printed_through = printed_through;
	status = ydb_tp_st(tptoken, errstr, cb2, &args, NULL, 0, NULL);
	if (YDB_TP_RESTART == status)
		return status;
	if (is_user_specific)
	{
		if (4 > *printed_through)
		{
			PRINT_THREAD_ID(file, tid);
			fprintf(file, "CALLBACK1 will check that the return from ydb_tp_st()2 is actually USER_SPECIFIC_STATUS_CODE.\n");
		}
		YDB_ASSERT(USER_SPECIFIC_STATUS_CODE == status);
	}
	else
	{
		if (4 > *printed_through)
		{
			PRINT_THREAD_ID(file, tid);
			fprintf(file, "CALLBACK1 will check that the return from ydb_tp_st()2 is actually YDB_TP_ROLLBACK.\n");
		}
		YDB_ASSERT(YDB_TP_ROLLBACK == status);
	}
	if (4 > *printed_through)
	{
		PRINT_THREAD_ID(file, tid);
		fprintf(file, "Since control has returned from ydb_tp_st()2, CALLBACK1 will do some more updates ");
		fprintf(file, "(third set of updates) using ydb_set_st() then return YDB_OK.\n");
		*printed_through = 4;
	}
	subscript.buf_addr = "3";
	status = ydb_set_st(tptoken, errstr, varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_OK == status);

	return YDB_OK;
}

int callback2_common(uint64_t tptoken, ydb_buffer_t* errstr, ydb_buffer_t *varname, FILE* file, int tid, int *printed_through)
{
	int		status;
	ydb_buffer_t	subscript, value;

	subscript.len_alloc = subscript.len_used = 1;
	subscript.buf_addr = "2";
	value.len_alloc = value.len_used = 3;
	value.buf_addr = "set";
	if (2 > *printed_through)
	{
		PRINT_THREAD_ID(file, tid);
		fprintf(file, "CALLBACK2 will do some db updates (second set of updates) using ydb_set_st()\n");
		*printed_through = 2;
	}
	status = ydb_set_st(tptoken, errstr, varname, 1, &subscript, &value);
		return status;
}

int callback1(uint64_t tptoken, ydb_buffer_t* errstr, struct transargs *args)
{
	ydb_buffer_t	*varname;
	FILE		*file;
	int		tid, *printed_through;

	varname = args->varname;
	file = args->file;
	tid = args->tid;
	printed_through = args->printed_through;
	return callback1_common(tptoken, errstr, varname, 0, file, tid, printed_through);
}

int callback2(uint64_t tptoken, ydb_buffer_t* errstr, struct transargs *args)
{
	ydb_buffer_t	*varname;
	FILE		*file;
	int		status, tid, *printed_through;

	varname = args->varname;
	file = args->file;
	tid = args->tid;
	printed_through = args->printed_through;
	status = callback2_common(tptoken, errstr, varname, file, tid, printed_through);
	if (YDB_TP_RESTART == status)
		return status;
	if (3 > *printed_through)
	{
		PRINT_THREAD_ID(file, tid);
		fprintf(file, "CALLBACK2 will return YDB_TP_ROLLBACK\n");
		*printed_through = 3;
	}
	return YDB_TP_ROLLBACK;
}

int callback1_us(uint64_t tptoken, ydb_buffer_t* errstr, struct transargs *args)
{
	ydb_buffer_t	*varname;
	FILE		*file;
	int		tid, *printed_through;

	varname = args->varname;
	file = args->file;
	tid = args->tid;
	printed_through = args->printed_through;
	return callback1_common(tptoken, errstr, varname, 1, file, tid, printed_through);
}

int callback2_us(uint64_t tptoken, ydb_buffer_t* errstr, struct transargs *args)
{
	ydb_buffer_t	*varname;
	FILE		*file;
	int		status, tid, *printed_through;

	varname = args->varname;
	file = args->file;
	tid = args->tid;
	printed_through = args->printed_through;
	status = callback2_common(tptoken, errstr, varname, file, tid, printed_through);
	if (YDB_TP_RESTART == status)
		return status;
	if (3 > *printed_through)
	{
		PRINT_THREAD_ID(file, tid);
		fprintf(file, "CALLBACK2 will return USER_SPECIFIC_STATUS_CODE\n");
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
	status = ydb_get_st(YDB_NOTTP, NULL, &varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_OK == status)
	subscript.buf_addr = "2";
	status = ydb_get_st(YDB_NOTTP, NULL, &varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_ERR_GVUNDEF == status)
	subscript.buf_addr = "3";
	status = ydb_get_st(YDB_NOTTP, NULL, &varname, 1, &subscript, &value);
	YDB_ASSERT(YDB_OK == status);
	free(value.buf_addr);
}
