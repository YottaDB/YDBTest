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
#include <stdio.h>

#define ERRBUF_SIZE 	1024
#define MAX_SUBS	32

#define SUBSCR 		"1"
#define VALUE		"test"

int main(int argc, char** argv)
{
	unsigned int	status, copy_done, ret_value, subs;
	ydb_buffer_t	var1, var2, subscr, value, subsbuff[MAX_SUBS + 1];
	char		errbuf[ERRBUF_SIZE], var1_buf[64], var2_buf[64], substrlit[MAX_SUBS][3];

	printf("### Test data return in ydb_data_st() of %s Variables ###\n", argv[1]); fflush(stdout);
	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(SUBSCR, &subscr);
	YDB_LITERAL_TO_BUFFER(VALUE, &value);

	var1.buf_addr = &var1_buf[0];
	var1.len_used = 0;
	var1.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[2], &var1, copy_done);
	YDB_ASSERT(copy_done);
	var1.buf_addr[var1.len_used] = '\0';

	var2.buf_addr = &var2_buf[0];
	var2.len_used = 0;
	var2.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[3], &var2, copy_done);
	YDB_ASSERT(copy_done);
	var2.buf_addr[var2.len_used] = '\0';

	printf("Initialize the ydb_buffer_t for 31-depth %s variable\n", argv[1]);
	for (subs = 0; subs < MAX_SUBS; subs++)
	{
		if (subs == MAX_SUBS-1)
			subsbuff[subs].len_used = subsbuff[subs].len_alloc =  MAX_SUBS;
		else
			subsbuff[subs].len_used = subsbuff[subs].len_alloc = 0;

		subsbuff[subs].buf_addr = substrlit[subs];
	}
	printf("Perform ydb_data_st() on %s, which has no value and no subtree\n", var1.buf_addr); fflush(stdout);
	status = ydb_data_st(YDB_NOTTP, NULL, &var1, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value != 0)
	{
		printf("ydb_data_st() returned the wrong value: %d\n", ret_value);
		fflush(stdout);
	} else
	{
		printf("ydb_data_st() returned %d\n", ret_value); fflush(stdout);
		fflush(stdout);
	}
	printf("Set the %s variable %s to %s\n", argv[1], var1.buf_addr, value.buf_addr); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &var1, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Perform ydb_data_st() on %s, which has a value and no subtree\n", var1.buf_addr); fflush(stdout);
	status = ydb_data_st(YDB_NOTTP, NULL, &var1, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value != 1)
	{
		printf("ydb_data_st() returned the wrong value: %d\n", ret_value);
		fflush(stdout);
	} else
	{
		printf("ydb_data_st() returned %d\n", ret_value); fflush(stdout);
	}
	printf("Set the %s variable %s(", argv[1], var2.buf_addr);
	for (subs = 0; subs < MAX_SUBS; subs++)
	{
		if(subsbuff[subs].len_used == 0)
			printf(",");
		else
			printf("1)");
	}
	printf(" to %s\n", value.buf_addr); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &var2, 31, subsbuff, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Perform ydb_data_st() on %s, which has no value and a subtree\n", var2.buf_addr); fflush(stdout);
	status = ydb_data_st(YDB_NOTTP, NULL, &var2, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value != 10)
	{
		printf("ydb_data_st() returned the wrong value: %d\n", ret_value);
		fflush(stdout);
	} else
	{
		printf("ydb_data_st() returned %d\n", ret_value); fflush(stdout);
	}
	printf("Set the %s variable %s to %s\n", argv[1], var2.buf_addr, value.buf_addr); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &var2, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Perform ydb_data_st() on %s, which has a value and a subtree\n", var2.buf_addr); fflush(stdout);
	status = ydb_data_st(YDB_NOTTP, NULL, &var2, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value != 11)
	{
		printf("ydb_data_st() returned the wrong value: %d\n", ret_value);
		fflush(stdout);
	} else
	{
		printf("ydb_data_st() returned %d\n", ret_value); fflush(stdout);
	}
	return YDB_OK;
}
