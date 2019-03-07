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
#include <stdio.h>

#define ERRBUF_SIZE 	1024

#define STR_STRING	"X\0ABC"

int main()
{
	int 		status;
	ydb_buffer_t	strstring, zwrstring, ret_value;
	char 		errbuf[ERRBUF_SIZE], zwrstringbuf[64], retvaluebuf[64];

	printf("### Test error scenarios of ydb_str2zwr_st() and ydb_zwr2str_st()\n"); fflush(stdout);

	/* Initialize varname and value buffers */

	YDB_LITERAL_TO_BUFFER(STR_STRING, &strstring);

	zwrstring.buf_addr = retvaluebuf;
	zwrstring.len_alloc = sizeof(retvaluebuf);
	zwrstring.len_used = 0;
	ret_value.buf_addr = retvaluebuf;
	ret_value.len_alloc = sizeof(retvaluebuf);
	ret_value.len_used = 0;

	printf("# Test of INVSTRLEN error\n"); fflush(stdout);
	printf("# Attempting ydb_str2zwr_st() with zwr->len_alloc too short\n"); fflush(stdout);
	ret_value.len_alloc = 14;
	status = ydb_str2zwr_st(YDB_NOTTP, NULL, &strstring, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_str2zwr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	ret_value.len_alloc = sizeof(retvaluebuf);
	status = ydb_str2zwr_st(YDB_NOTTP, NULL, &strstring, &zwrstring);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_str2zwr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_zwr2str_st() with str->len_alloc too short\n"); fflush(stdout);
	ret_value.len_alloc = 4;
	status = ydb_zwr2str_st(YDB_NOTTP, NULL, &zwrstring, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_zwr2str_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	ret_value.len_alloc = sizeof(retvaluebuf);
	printf("# Test of PARAMINVALID error\n"); fflush(stdout);
	printf("# Attempting ydb_str2zwr_st() with zwr = NULL\n"); fflush(stdout);
	status = ydb_str2zwr_st(YDB_NOTTP, NULL, &strstring, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_str2zwr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_str2zwr_st() with zwr->buf_addr set to NULL and zwr->len_used is non-zero.\n"); fflush(stdout);
	ret_value.buf_addr = NULL;
	status = ydb_str2zwr_st(YDB_NOTTP, NULL, &strstring, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_str2zwr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	ret_value.buf_addr = retvaluebuf;
	printf("# Attempting ydb_zwr2str_st() with str = NULL\n"); fflush(stdout);
	status = ydb_zwr2str_st(YDB_NOTTP, NULL, &strstring, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_zwr2str_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_str2zwr_st() with zwr->buf_addr set to NULL and zwr->len_used is non-zero.\n"); fflush(stdout);
	ret_value.buf_addr = NULL;
	status = ydb_zwr2str_st(YDB_NOTTP, NULL, &zwrstring, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_zwr2str_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	ret_value.buf_addr = retvaluebuf;
	return YDB_OK;
}
