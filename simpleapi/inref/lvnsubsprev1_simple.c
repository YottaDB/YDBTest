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

#define BASEVAR		"baselv"
#define PREVVAR		"aprevlv"
#define SUBSCR1		"42"
#define SUBSCR2		"answer"
#define PREVSUBSCR1	"41"
#define PREVSUBSCR2	"answar"
#define VALUE1		"A question"
#define VALUE2		"One less than 43"
#define VALUE3		"Life, the universe, and everything"

int main()
{
	int		i, status;
	ydb_buffer_t	basevar, prevvar, subscr[2], prevsubscr[2], value1, value2, value3, badbasevar, ret_value;
	char		errbuf[ERRBUF_SIZE], retvaluebuff[64];
	ydb_string_t	zwrarg;

	printf("### Test simple ydb_subscript_previous_s() of Local Variables ###\n"); fflush(stdout);
	/* Initialize varname, subscript, and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	YDB_STRLIT_TO_BUFFER(&prevvar, PREVVAR);
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
	printf("Set a local variable (and a prev local variable) with 0 subscripts\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [1a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&prevvar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [1b]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Set local variable node (and a prev subscript) with 1 subscript\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 1, subscr, &value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [2a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	YDB_STRLIT_TO_BUFFER(&prevsubscr[0], PREVSUBSCR1);
	status = ydb_set_s(&basevar, 1, prevsubscr, &value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [2b]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Set a local variable node (and a prev subscript) with 2 subscripts\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 2, subscr, &value3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [3a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	prevsubscr[0] = subscr[0];
	YDB_STRLIT_TO_BUFFER(&prevsubscr[1], PREVSUBSCR2);
	status = ydb_set_s(&basevar, 2, prevsubscr, &value3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [3b]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Get prev local variable of local variable with 0 subscripts\n"); fflush(stdout);
	status = ydb_subscript_previous_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [0a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("ydb_subscript_previous_s() returned [%s]\n", ret_value.buf_addr);
	printf("Get prev subscript of local variable with 1 subscript\n"); fflush(stdout);
	status = ydb_subscript_previous_s(&basevar, 1, subscr, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [1a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("ydb_subscript_previous_s() returned [%s]\n", ret_value.buf_addr);
	printf("Get prev subscript of local variable with 2 subscripts\n"); fflush(stdout);
	status = ydb_subscript_previous_s(&basevar, 2, subscr, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [2a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("ydb_subscript_previous_s() returned [%s]\n", ret_value.buf_addr);
	printf("Demonstrate our progress by executing a ZWRITE in a call-in\n"); fflush(stdout);
	zwrarg.address = NULL;			/* Create a null string argument so dumps all locals */
	zwrarg.length = 0;
	status = ydb_ci("driveZWRITE", &zwrarg);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("driveZWRITE error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	return YDB_OK;
}
