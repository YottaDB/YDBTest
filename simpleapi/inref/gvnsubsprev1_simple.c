/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.	*
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
#define PREVVAR		"^aprevlv"
#define SUBSCR1		"42"
#define SUBSCR2		"answer"
#define PREVSUBSCR1	"41"
#define PREVSUBSCR2	"answar"
#define VALUE1		"A question"
#define VALUE2		"One less than 43"
#define VALUE3		"Life, the universe, and everything"

int main()
{
	int		i, status, ret_test;
	ydb_buffer_t	basevar, prevvar, subscr[2], prevsubscr[2], value1, value2, value3, badbasevar, ret_value;
	char		errbuf[ERRBUF_SIZE], retvaluebuff[64], rettestbuff[64];

	printf("### Test simple ydb_subscript_previous_s() of Global Variables ###\n"); fflush(stdout);
	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(PREVVAR, &prevvar);
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
	printf("# Set a global variable (and a prev global variable) with 0 subscripts\n"); fflush(stdout);
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
	printf("# Set global variable node (and a prev subscript) with 1 subscript\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 1, subscr, &value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [2a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	YDB_LITERAL_TO_BUFFER(PREVSUBSCR1, &prevsubscr[0]);
	status = ydb_set_s(&basevar, 1, prevsubscr, &value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [2b]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Set a global variable node (and a prev subscript) with 2 subscripts\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 2, subscr, &value3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [3a]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	prevsubscr[0] = subscr[0];
	YDB_LITERAL_TO_BUFFER(PREVSUBSCR2, &prevsubscr[1]);
	status = ydb_set_s(&basevar, 2, prevsubscr, &value3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [3b]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("\n# Get prev global variable of global variable with 0 subscripts\n"); fflush(stdout);
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
	printf("# Get prev global variable of global variable with 0 subscripts\n"); fflush(stdout);
	ret_test = ret_value.len_used;
	memcpy(rettestbuff, ret_value.buf_addr, ret_value.len_used);
	status = ydb_subscript_previous_s(&prevvar, 0, NULL, &ret_value);
	if (YDB_ERR_NODEEND != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_next_s() did not return YDB_ERR_NODEEND: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value.len_used != ret_test || memcmp(rettestbuff, ret_value.buf_addr, ret_value.len_used) != 0)
	{
		printf("ydb_subscript_next_s(): *ret_value was altered\n");
		fflush(stdout);
	} else
	{
		printf("ydb_subscript_next_s() returned YDB_ERR_NODEEND\n");
		printf("*ret_value.len_used and ret_value.buf_addr were unaltered.\n");
		fflush(stdout);
	}
	printf("\n# Get prev subscript of global variable with 1 subscript\n"); fflush(stdout);
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
	printf("# Get prev global variable of global variable with 1 subscripts\n"); fflush(stdout);
	ret_test = ret_value.len_used;
	memcpy(rettestbuff, ret_value.buf_addr, ret_value.len_used);
	status = ydb_subscript_previous_s(&prevvar, 0, NULL, &ret_value);
	if (YDB_ERR_NODEEND != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_next_s() did not return YDB_ERR_NODEEND: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value.len_used != ret_test || memcmp(rettestbuff, ret_value.buf_addr, ret_value.len_used) != 0)
	{
		printf("ydb_subscript_next_s(): *ret_value was altered\n");
		fflush(stdout);
	} else
	{
		printf("ydb_subscript_next_s() returned YDB_ERR_NODEEND\n");
		printf("*ret_value.len_used and ret_value.buf_addr were unaltered.\n");
		fflush(stdout);
	}
	printf("\n# Get prev subscript of global variable with 2 subscripts\n"); fflush(stdout);
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
	printf("# Get prev global variable of global variable with 2 subscripts\n"); fflush(stdout);
	ret_test = ret_value.len_used;
	memcpy(rettestbuff, ret_value.buf_addr, ret_value.len_used);
	status = ydb_subscript_previous_s(&prevvar, 0, NULL, &ret_value);
	if (YDB_ERR_NODEEND != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_next_s() did not return YDB_ERR_NODEEND: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value.len_used != ret_test || memcmp(rettestbuff, ret_value.buf_addr, ret_value.len_used) != 0)
	{
		printf("ydb_subscript_next_s(): *ret_value was altered\n");
		fflush(stdout);
	} else
	{
		printf("ydb_subscript_next_s() returned YDB_ERR_NODEEND\n");
		printf("*ret_value.len_used and ret_value.buf_addr were unaltered.\n");
		fflush(stdout);
	}
	printf("\n# Demonstrate our progress by executing a gvnZWRITE in a call-in\n"); fflush(stdout);
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
