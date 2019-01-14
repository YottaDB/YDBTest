/****************************************************************
 *								*
 * Copyright (c) 2017-2019 YottaDB LLC. and/or its subsidiaries.*
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

#define VALUE		"1"
#define INCR		"2"

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
	int 		status, copy_done, subs;
	ydb_buffer_t 	basevar, ret_value, subsbuff[MAX_SUBS + 1], value, incr;
	char 		errbuf[ERRBUF_SIZE], basevarbuf[64], retvaluebuf[64], subsstrlit[MAX_SUBS][3];

	basevar.buf_addr = &basevarbuf[0];
	basevar.len_used = 0;
	basevar.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[2], &basevar, copy_done);
	YDB_ASSERT(copy_done);
	basevar.buf_addr[basevar.len_used] = '\0';

	ret_value.buf_addr = &retvaluebuf[0];
	ret_value.len_used = 0;
	ret_value.len_alloc = 64;

	YDB_LITERAL_TO_BUFFER(VALUE, &value);
	YDB_LITERAL_TO_BUFFER(INCR, &incr);

	printf("### Test 31-level (max-deep) subscripts can be used while using ydb_incr_s() of %s Variables ###\n", argv[1]); fflush(stdout);
	printf("# Each variable will be initially set to 1, and then incremented by 2 to result in 3\n"); fflush(stdout);

	for (subs = 0; subs < MAX_SUBS; subs++)
	{
		printf("# Set a %s variable with %d subscripts to 1\n", argv[1], subs); fflush(stdout);
		subsbuff[subs].len_used = subsbuff[subs].len_alloc = sprintf(subsstrlit[subs], "%d", subs);
		subsbuff[subs].buf_addr = subsstrlit[subs];
		status = ydb_set_s(&basevar, subs, subsbuff, &value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s() : subsbuff [%d]: %s\n", subs, errbuf);
			fflush(stdout);
			return YDB_OK;
		}

		printf("# Increment "); fflush(stdout);
		print_subs(subs, &basevar, subsbuff);
		printf(" by %s\n", value.buf_addr); fflush(stdout);
		status = ydb_incr_s(&basevar, subs, subsbuff, &incr, &ret_value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s() : subsbuff [%d]: %s\n", subs, errbuf);
			fflush(stdout);
			return YDB_OK;
		}
		printf("# To confirm the value has incremented, get the new value\n"); fflush(stdout);
		status = ydb_get_s(&basevar, subs, subsbuff, &ret_value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		}
		if (ret_value.len_used != 1)
		{
			printf("ydb_incr_s() resulted in an incorrect response\n");
			fflush(stdout);
		} else
		{
			ret_value.buf_addr[ret_value.len_used] = '\0';
			if (memcmp(ret_value.buf_addr, "3", ret_value.len_used) == 0)
			{
				printf("ydb_get_s() returns %s\n", ret_value.buf_addr);
				fflush(stdout);
			}
		}
	}

	return YDB_OK;
}
