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

#define SUBSCR 		"1"
#define VALUE		"test"

int main(int argc, char** argv)
{
	unsigned int	status, copy_done, ret_value;
	ydb_buffer_t	var1, var2, subscr, value;
	char		errbuf[ERRBUF_SIZE], var1_buf[64], var2_buf[64];

	printf("### Test data return in ydb_data_s() of %s Variables ###\n", argv[1]); fflush(stdout);
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

	printf("Perform ydb_data_s() on %s, which has no value and no subtree\n", var1.buf_addr); fflush(stdout);
	status = ydb_data_s(&var1, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value != 0)
	{
		printf("ydb_data_s() returned the wrong value: %d\n", ret_value);
		fflush(stdout);
	} else
	{
		printf("ydb_data_s() returned %d\n", ret_value); fflush(stdout);
		fflush(stdout);
	}
	printf("Set the %s variable %s to %s\n", argv[1], var1.buf_addr, value.buf_addr); fflush(stdout);
	status = ydb_set_s(&var1, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Perform ydb_data_s() on %s, which has a value and no subtree\n", var1.buf_addr); fflush(stdout);
	status = ydb_data_s(&var1, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value != 1)
	{
		printf("ydb_data_s() returned the wrong value: %d\n", ret_value);
		fflush(stdout);
	} else
	{
		printf("ydb_data_s() returned %d\n", ret_value); fflush(stdout);
	}
	printf("Set the %s variable %s(1) to %s\n", argv[1], var2.buf_addr, value.buf_addr); fflush(stdout);
	status = ydb_set_s(&var2, 1, &subscr, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Perform ydb_data_s() on %s, which has no value and a subtree\n", var2.buf_addr); fflush(stdout);
	status = ydb_data_s(&var2, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value != 10)
	{
		printf("ydb_data_s() returned the wrong value: %d\n", ret_value);
		fflush(stdout);
	} else
	{
		printf("ydb_data_s() returned %d\n", ret_value); fflush(stdout);
	}
	printf("Set the %s variable %s to %s\n", argv[1], var2.buf_addr, value.buf_addr); fflush(stdout);
	status = ydb_set_s(&var2, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Perform ydb_data_s() on %s, which has a value and a subtree\n", var2.buf_addr); fflush(stdout);
	status = ydb_data_s(&var2, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (ret_value != 11)
	{
		printf("ydb_data_s() returned the wrong value: %d\n", ret_value);
		fflush(stdout);
	} else
	{
		printf("ydb_data_s() returned %d\n", ret_value); fflush(stdout);
	}
	return YDB_OK;
}
