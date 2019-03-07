/****************************************************************
 *								*
 * Copyright (c) 2017-2019 YottaDB LLC and/or its subsidiaries. *
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

#define BASEVAR "baselv"
#define SUBSCR1	"42"
#define SUBSCR2 "answer:"
#define VALUE1	"A question"
#define VALUE2	"One less than 43"
#define VALUE3 	"Life, the universe, and everything"

int main()
{
	int		i, status;
	ydb_buffer_t	basevar, subscr[2], subscr32[32], value1, value2, value3, badbasevar, ret_value;
	char		errbuf[ERRBUF_SIZE], retvaluebuff[64];
	ydb_string_t	zwrarg;

	printf("### Test simple gets in ydb_get_st() of Local Variables ###\n"); fflush(stdout);
	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(SUBSCR1, &subscr[0]);
	YDB_LITERAL_TO_BUFFER(SUBSCR2, &subscr[1]);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);
	YDB_LITERAL_TO_BUFFER(VALUE2, &value2);
	YDB_LITERAL_TO_BUFFER(VALUE3, &value3);
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
	printf("Set a local variable with 0 subscripts\n"); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [1]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Set a local variable with 1 subscript\n"); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 1, subscr, &value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Set a local variable with 2 subscripts\n"); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 2, subscr, &value3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [3]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Get the local variable with 0 subscripts\n"); fflush(stdout);
	status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_st() [1a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("ydb_get_st() [1b] : ydb_get_st() returned [%s]\n", ret_value.buf_addr);
	printf("Get the local variable with 1 subscript\n"); fflush(stdout);
	status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 1, subscr, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_st() [2a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("ydb_get_st() [1b] : ydb_get_st() returned [%s]\n", ret_value.buf_addr);
	printf("Get the local variable with 2 subscripts\n"); fflush(stdout);
	status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 2, subscr, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_st() [2a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("ydb_get_st() [1b] : ydb_get_st() returned [%s]\n", ret_value.buf_addr);
	printf("Demonstrate our progress by executing a ZWRITE in a call-in\n"); fflush(stdout);
	zwrarg.address = NULL;			/* Create a null string argument so dumps all locals */
	zwrarg.length = 0;
	status = ydb_ci_t(YDB_NOTTP, NULL, "driveZWRITE", &zwrarg);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("driveZWRITE error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	return YDB_OK;
}
