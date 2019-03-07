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
#define MAX_SUBS	32

#define SUBSCR 		"1"
#define VALUE		"test"

void ZWrite( char* var_type )
{
	int 		status;
	char 		errbuf[ERRBUF_SIZE];
	ydb_string_t	zwrarg;

	if (memcmp(var_type, "Global", 5) == 0)
	{
		status = ydb_ci_t(YDB_NOTTP, NULL, "gvnZWRITE");
		if (status != YDB_OK)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("gvnZWRITE error: %s\n", errbuf);
			fflush(stdout);
		}
	} else
	{
		zwrarg.address = NULL;
		zwrarg.length = 0;
		status = ydb_ci_t(YDB_NOTTP, NULL, "driveZWRITE", &zwrarg);
		if (status != YDB_OK)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("driveZWRITE error: %s\n", errbuf);
			fflush(stdout);
		}
	}
}

void print_subs(int subs, ydb_buffer_t *basevar, ydb_buffer_t *ret_array)
{
	int	j;
	printf("%s(", basevar->buf_addr);
	for (j = 0; j < subs; j++)
	{
		if (j == (subs -1))
			printf("%s", ret_array[j].buf_addr);
		else
			printf("%s,", ret_array[j].buf_addr);
	}
	printf(")");
	fflush(stdout);
}

int main(int argc, char** argv)
{
	int 		status, copy_done, subs, j;
	ydb_buffer_t	var1, var2, ret_value, value, subsbuff[MAX_SUBS + 1];
	char 		errbuf[ERRBUF_SIZE], var1buf[64], var2buf[64], retvaluebuf[64], substrlit[MAX_SUBS][3];

	printf("### Test simple ydb_delete_st() of %s Variables ###\n", argv[1]); fflush(stdout);
	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(VALUE, &value);

	var1.buf_addr = &var1buf[0];
	var1.len_used = 0;
	var1.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[2], &var1, copy_done);
	YDB_ASSERT(copy_done);
	var1.buf_addr[var1.len_used]='\0';

	var2.buf_addr = &var2buf[0];
	var2.len_used = 0;
	var2.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[3], &var2, copy_done);
	YDB_ASSERT(copy_done);
	var2.buf_addr[var2.len_used]='\0';

	ret_value.buf_addr = retvaluebuf;
	ret_value.len_alloc = sizeof(retvaluebuf);
	ret_value.len_used = 0;

	printf("# Initialize the ydb_buffer_t for 31-depth %s variable\n", argv[1]); fflush(stdout);
	printf("# Set %s variable %s with subscripts up to 31 to %s\n", argv[1], var1.buf_addr, value.buf_addr); fflush(stdout);
	for (subs = 0; subs < MAX_SUBS; subs++)
	{
		subsbuff[subs].len_used = subsbuff[subs].len_alloc = sprintf(substrlit[subs], "%d", subs);
		subsbuff[subs].buf_addr = substrlit[subs];
		status = ydb_set_st(YDB_NOTTP, NULL, &var1, subs, subsbuff, &value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s[%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
			return YDB_OK;
		}

	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	printf("# Test ydb_delete_st() with %s variable ", argv[1]);
	print_subs(31, &var1, subsbuff);
	printf(" and deltype = YDB_DEL_NODE\n");
	fflush(stdout);
	status = ydb_delete_st(YDB_NOTTP, NULL, &var1, 31, subsbuff, YDB_DEL_NODE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	printf("# Test ydb_delete_st() with %s variable ", argv[1]);
	print_subs(16, &var1, subsbuff);
	printf(" and deltype = YDB_DEL_NODE\n");
	fflush(stdout);
	status = ydb_delete_st(YDB_NOTTP, NULL, &var1, 16, subsbuff, YDB_DEL_NODE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	printf("# Test ydb_delete_st() with %s variable ", argv[1]);
	print_subs(1, &var1, subsbuff);
	printf(" and deltype = YDB_DEL_NODE\n");
	fflush(stdout);
	status = ydb_delete_st(YDB_NOTTP, NULL, &var1, 1, subsbuff, YDB_DEL_NODE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	status = ydb_delete_st(YDB_NOTTP, NULL, &var1, 0, NULL, YDB_DEL_TREE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Set %s variable %s with subscripts up to 31 to %s\n", argv[1], var2.buf_addr, value.buf_addr); fflush(stdout);
	for (subs = 0; subs < MAX_SUBS; subs++)
	{
		status = ydb_set_st(YDB_NOTTP, NULL, &var2, subs, subsbuff, &value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s[%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
			return YDB_OK;
		}
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	printf("# Test ydb_delete_st() with %s variable", argv[1]);
	print_subs(31, &var2, subsbuff);
	printf(" and deltype = YDB_DEL_TREE\n");
	fflush(stdout);
	status = ydb_delete_st(YDB_NOTTP, NULL, &var2, 31, subsbuff, YDB_DEL_TREE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	printf("# Test ydb_delete_st() with %s variable ", argv[1]);
	print_subs(16, &var2, subsbuff);
	printf(" and deltype = YDB_DEL_TREE\n");
	fflush(stdout);
	status = ydb_delete_st(YDB_NOTTP, NULL, &var2, 16, subsbuff, YDB_DEL_TREE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	printf("# Test ydb_delete_st() with %s variable ", argv[1]);
	print_subs(1, &var2, subsbuff);
	printf(" and deltype = YDB_DEL_TREE\n");
	fflush(stdout);
	status = ydb_delete_st(YDB_NOTTP, NULL, &var2, 1, subsbuff, YDB_DEL_TREE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	return YDB_OK;
}
