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
#include <stdlib.h>

#define ERRBUF_SIZE	1024
#define	MAX_SUBS	32

#define VALUE	"test"


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
	printf(")\n");
	fflush(stdout);
}

int main(int argc, char** argv)
{
	int		status, subs, k, i, tmpsubs, copy_done, ret_test;
	ydb_buffer_t	basevar, value, subsbuff[MAX_SUBS + 1], ret_value1[MAX_SUBS], ret_value2[MAX_SUBS];
	char		errbuf[ERRBUF_SIZE], basevarbuff[64], subsstrlit[MAX_SUBS][3], retvaluebuff1[MAX_SUBS][64], retvaluebuff2[MAX_SUBS][64];
	char		rettestbuff[64];

	/* Initialize varname, subscript, and value buffers */
	basevar.buf_addr = &basevarbuff[0];
	basevar.len_used = 0;
	basevar.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[2], &basevar, copy_done);
	YDB_ASSERT(copy_done);
	basevar.buf_addr[basevar.len_used]='\0';
	YDB_LITERAL_TO_BUFFER(VALUE, &value);

	for (i = 0; i <= MAX_SUBS; i++)
	{
		ret_value1[i].buf_addr = retvaluebuff1[i];
		ret_value1[i].len_alloc = sizeof(retvaluebuff1[i]);
		ret_value2[i].buf_addr = retvaluebuff2[i];
		ret_value2[i].len_alloc = sizeof(retvaluebuff2[i]);
	}

	printf("### Test 31-level (max-deep) subscripts can be got using ydb_node_previous_s() of %s Variables ###\n", argv[1]); fflush(stdout);
	for (subs = 0; subs < MAX_SUBS; subs++)
	{
		printf("# Set a %s variable (and next subscript) with %d subscripts\n", argv[1], subs); fflush(stdout);
		subsbuff[subs].len_used = subsbuff[subs].len_alloc = ret_value1[subs].len_used = ret_value2[subs].len_used = sprintf(subsstrlit[subs], "%d", subs+1);
		subsbuff[subs].buf_addr = ret_value1[subs].buf_addr = ret_value2[subs].buf_addr = subsstrlit[subs];
		status = ydb_set_s(&basevar, subs, subsbuff, &value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s() [1] : subsbuff [%d]: %s\n", subs, errbuf);
			fflush(stdout);
			return YDB_OK;
		}
	}

	printf("Starting at "); fflush(stdout);
	print_subs(31, &basevar, ret_value2);
	for (subs = MAX_SUBS-1; subs >= 0; subs--)
	{
		tmpsubs = MAX_SUBS;
		printf("# Get the previous node after a node at %d subscript depth\n", subs); fflush(stdout);

		if (subs % 2)
		{
			ret_test = ret_value1[subs].len_used;
			memcpy(rettestbuff, ret_value1[subs].buf_addr, ret_value1[subs].len_used);
			status = ydb_node_previous_s(&basevar, subs, ret_value2, &tmpsubs, ret_value1);
			if (YDB_OK != status)
			{
				if (YDB_ERR_NODEEND != status)
				{
					ydb_zstatus(errbuf, ERRBUF_SIZE);
					printf("ydb_node_previous_s() [odd] : subsbuff [%d]: %s\n", subs, errbuf);
					fflush(stdout);
					return YDB_OK;
				} else if (0 != tmpsubs)
				{
					printf("ydb_node_previous_s(): *ret_subs_used was set/left as %d instead of being set to 0\n", tmpsubs);
					fflush(stdout);
				} else if (ret_test != ret_value1[subs].len_used || memcmp(rettestbuff, ret_value1[subs].buf_addr, ret_value1[subs].len_used) != 0)
				{
					printf("ydb_node_next_s(): *ret_value was altered\n");
					fflush(stdout);
				} else
				{
					printf("ydb_node_previous_s() returned YDB_ERR_NODEEND\n");
					printf("*ret_subs_used was set to 0\n");
					printf("*ret_value was unaltered\n");
					fflush(stdout);
				}
			} else if (tmpsubs != subs-1)
			{
				printf("ydb_node_previous_s() returned the wrong amount of subscripts: %d\n", tmpsubs);
				fflush(stdout);
			} else
			{
				for (k = 0; k <= subs; k++)
					ret_value1[k].buf_addr[ret_value1[k].len_used] = '\0';
				printf("ydb_node_previous_s() returned "); fflush(stdout);
				print_subs(tmpsubs, &basevar, ret_value1);
			}
		} else
		{
			ret_test = ret_value2[subs].len_used;
			memcpy(rettestbuff, ret_value2[subs].buf_addr, ret_value2[subs].len_used);
			status = ydb_node_previous_s(&basevar, subs, ret_value1, &tmpsubs, ret_value2);
			if (YDB_OK != status)
			{
				if (YDB_ERR_NODEEND != status)
				{
					ydb_zstatus(errbuf, ERRBUF_SIZE);
					printf("ydb_node_previous_s() [even] : subsbuff [%d]: %s\n", subs, errbuf);
					fflush(stdout);
					return YDB_OK;
				} else if (0 != tmpsubs)
				{
					printf("ydb_node_previous_s(): *ret_subs_used was set/left as %d instead of being set to 0\n", tmpsubs);
					fflush(stdout);
				} else if (ret_test != ret_value2[subs].len_used || memcmp(rettestbuff, ret_value2[subs].buf_addr, ret_value2[subs].len_used) != 0)
				{
					printf("ydb_node_next_s(): *ret_value was altered\n");
					fflush(stdout);
				} else
				{
					printf("ydb_node_previous_s() returned YDB_ERR_NODEEND\n");
					printf("*ret_subs_used was set to 0\n");
					printf("*ret_value was unaltered\n");
					fflush(stdout);
				}
			} else if (tmpsubs != subs-1)
			{
				printf("ydb_node_previous_s() returned the wrong amount of subscripts: %d\n", tmpsubs);
				fflush(stdout);
			} else
			{
				for (k = 0; k <= subs; k++)
					ret_value2[k].buf_addr[ret_value2[k].len_used] = '\0';
				printf("ydb_node_previous_s() returned ");
				fflush(stdout);
				print_subs(tmpsubs, &basevar, ret_value2);
			}
		}

	}
	return YDB_OK;
}
