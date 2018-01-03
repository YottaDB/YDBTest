/****************************************************************
 *								*
 * Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.*
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
#include <string.h>

#define ERRBUF_SIZE	1024

#define BASEVAR		"^baselv"
#define NEXTVAR		"^nextlv"
#define SUBSCR1		"42"
#define SUBSCR2		"answer"
#define NEXTSUBSCR1	"43"
#define NEXTSUBSCR2	"answer2"
#define VALUE1		"A question"
#define VALUE2		"One less than 43"
#define VALUE3		"Life, the universe, and everything"

int main()
{
	int		i, status;
	ydb_buffer_t	basevar, nextvar, subscr[2], nextsubscr[2], value1, value2, value3, badbasevar, ret_value;
	char		errbuf[ERRBUF_SIZE], retvaluebuff[64];

	printf("### Test simple ydb_subscript_next_s() of Global Variables ###\n"); fflush(stdout);
	/* Initialize varname, subscript, and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	YDB_STRLIT_TO_BUFFER(&nextvar, NEXTVAR);
	YDB_STRLIT_TO_BUFFER(&subscr[0], SUBSCR1);
	YDB_STRLIT_TO_BUFFER(&subscr[1], SUBSCR2);
	YDB_STRLIT_TO_BUFFER(&value1, VALUE1);
	YDB_STRLIT_TO_BUFFER(&value2, VALUE2);
	YDB_STRLIT_TO_BUFFER(&value3, VALUE3);
	ret_value.buf_addr = retvaluebuff;
	ret_value.len_alloc = sizeof(retvaluebuff);
	ret_value.len_used = 0;
	printf("Initialize call-in environment\n"); fflush(stdout);
	status = ydb_init();
	if (0 != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_init: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Set a global variable (and a next global variable) with 0 subscripts\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [1a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&nextvar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [1b]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Set global variable node (and a next subscript) with 1 subscript\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 1, subscr, &value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [2a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	YDB_STRLIT_TO_BUFFER(&nextsubscr[0], NEXTSUBSCR1);
	status = ydb_set_s(&basevar, 1, nextsubscr, &value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [2b]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Set a global variable node (and a next subscript) with 2 subscripts\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 2, subscr, &value3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [3a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	nextsubscr[0] = subscr[0];
	YDB_STRLIT_TO_BUFFER(&nextsubscr[1], NEXTSUBSCR2);
	status = ydb_set_s(&basevar, 2, nextsubscr, &value3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [3b]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Get next global variable of global variable with 0 subscripts\n"); fflush(stdout);
	status = ydb_subscript_next_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_next_s() [0a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("ydb_subscript_next_s() returned [%s]\n", ret_value.buf_addr);
	printf("Get next subscript of global variable with 1 subscript\n"); fflush(stdout);
	status = ydb_subscript_next_s(&basevar, 1, subscr, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_next_s() [1a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("ydb_subscript_next_s() returned [%s]\n", ret_value.buf_addr);
	printf("Get next subscript of global variable with 2 subscripts\n"); fflush(stdout);
	status = ydb_subscript_next_s(&basevar, 2, subscr, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_next_s() [2a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("ydb_subscript_next_s() returned [%s]\n", ret_value.buf_addr);
	printf("Demonstrate our progress by executing a gvnZWRITE in a call-in\n"); fflush(stdout);
	status = ydb_ci("gvnZWRITE");
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("gvnZWRITE error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	return YDB_OK;
}
