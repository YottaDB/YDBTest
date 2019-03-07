/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	*
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
#define NEXTVAR		"nextlv"
#define SUBSCR1		"42"
#define SUBSCR2		"answer"
#define NEXTSUBSCR1	"43"
#define NEXTSUBSCR2	"answer2"
#define VALUE1		"A question"
#define VALUE2		"One less than 43"
#define VALUE3		"Life, the universe, and everything"

int main()
{
	int		i, status, ret_test;
	ydb_buffer_t	basevar, nextvar, subscr[2], nextsubscr[2], value1, value2, value3, badbasevar, ret_value;
	char		errbuf[ERRBUF_SIZE], retvaluebuff[64], rettestbuff[64];
	ydb_string_t	zwrarg;

	printf("### Test simple ydb_subscript_next_st() of Local Variables ###\n"); fflush(stdout);
	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(NEXTVAR, &nextvar);
	YDB_LITERAL_TO_BUFFER(SUBSCR1, &subscr[0]);
	YDB_LITERAL_TO_BUFFER(SUBSCR2, &subscr[1]);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);
	YDB_LITERAL_TO_BUFFER(VALUE2, &value2);
	YDB_LITERAL_TO_BUFFER(VALUE3, &value3);
	ret_value.buf_addr = retvaluebuff;
	ret_value.len_alloc = sizeof(retvaluebuff);
	ret_value.len_used = 0;
	printf("# Initialize call-in environment\n"); fflush(stdout);
	status = ydb_init();
	if (0 != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_init: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Set a local variable (and a next local variable) with 0 subscripts\n"); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [1a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_st(YDB_NOTTP, NULL, &nextvar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [1b]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Set local variable node (and a next subscript) with 1 subscript\n"); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 1, subscr, &value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [2a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	YDB_LITERAL_TO_BUFFER(NEXTSUBSCR1, &nextsubscr[0]);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 1, nextsubscr, &value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [2b]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Set a local variable node (and a next subscript) with 2 subscripts\n"); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 2, subscr, &value3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [3a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	nextsubscr[0] = subscr[0];
	YDB_LITERAL_TO_BUFFER(NEXTSUBSCR2, &nextsubscr[1]);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 2, nextsubscr, &value3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [3b]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("\n# Get next local variable of local variable with 0 subscripts\n"); fflush(stdout);
	status = ydb_subscript_next_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_next_st() [0a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("ydb_subscript_next_st() returned [%s]\n", ret_value.buf_addr);
	printf("# Get next local variable of local variable with 0 subscripts\n"); fflush(stdout);
	ret_test = ret_value.len_used;
	memcpy(rettestbuff, ret_value.buf_addr, ret_value.len_used);
	status = ydb_subscript_next_st(YDB_NOTTP, NULL, &nextvar, 0, NULL, &ret_value);
	if (YDB_ERR_NODEEND != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_next_st() did not return YDB_ERR_NODEEND: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value.len_used != ret_test || memcmp(rettestbuff, ret_value.buf_addr, ret_value.len_used) != 0)
	{
		printf("ydb_subscript_next_st(): *ret_value was altered\n");
		fflush(stdout);
	} else
	{
		printf("ydb_subscript_next_st() returned YDB_ERR_NODEEND\n");
		printf("*ret_value.len_used and ret_value.buf_addr were unaltered.\n");
		fflush(stdout);
	}
	printf("\n# Get next subscript of local variable with 1 subscript\n"); fflush(stdout);
	status = ydb_subscript_next_st(YDB_NOTTP, NULL, &basevar, 1, subscr, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_next_st() [1a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("ydb_subscript_next_st() returned [%s]\n", ret_value.buf_addr);
	printf("# Get next local variable of local variable with 1 subscripts\n"); fflush(stdout);
	ret_test = ret_value.len_used;
	memcpy(rettestbuff, ret_value.buf_addr, ret_value.len_used);
	status = ydb_subscript_next_st(YDB_NOTTP, NULL, &nextvar, 0, NULL, &ret_value);
	if (YDB_ERR_NODEEND != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_next_st() did not return YDB_ERR_NODEEND: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value.len_used != ret_test || memcmp(rettestbuff, ret_value.buf_addr, ret_value.len_used) != 0)
	{
		printf("ydb_subscript_next_st(): *ret_value was altered\n");
		fflush(stdout);
	} else
	{
		printf("ydb_subscript_next_st() returned YDB_ERR_NODEEND\n");
		printf("*ret_value.len_used and ret_value.buf_addr were unaltered.\n");
		fflush(stdout);
	}
	printf("\n# Get next subscript of local variable with 2 subscripts\n"); fflush(stdout);
	status = ydb_subscript_next_st(YDB_NOTTP, NULL, &basevar, 2, subscr, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_next_st() [2a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("ydb_subscript_next_st() returned [%s]\n", ret_value.buf_addr);
	printf("# Get next local variable of local variable with 3 subscripts\n"); fflush(stdout);
	ret_test = ret_value.len_used;
	memcpy(rettestbuff, ret_value.buf_addr, ret_value.len_used);
	status = ydb_subscript_next_st(YDB_NOTTP, NULL, &nextvar, 0, NULL, &ret_value);
	if (YDB_ERR_NODEEND != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_next_st() did not return YDB_ERR_NODEEND: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value.len_used != ret_test || memcmp(rettestbuff, ret_value.buf_addr, ret_value.len_used) != 0)
	{
		printf("ydb_subscript_next_st(): *ret_value was altered\n");
		fflush(stdout);
	} else
	{
		printf("ydb_subscript_next_st() returned YDB_ERR_NODEEND\n");
		printf("*ret_value.len_used and ret_value.buf_addr were unaltered.\n");
		fflush(stdout);
	}
	printf("\n# Demonstrate our progress by executing a ZWRITE in a call-in\n"); fflush(stdout);
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
