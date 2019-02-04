/****************************************************************
 *								*
 * Copyright (c) 2018-2019 YottaDB LLC. and/or its subsidiaries.*
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

#define ERRBUF_SIZE	1024

#define BASEVAR "basevar"
#define SUBSCR 	"1"

int main(void)
{
	int		status;
	ydb_buffer_t	basevar, subscr, ret_value;
	char		errbuf[ERRBUF_SIZE], nextvarbuff[64], retvaluebuff[64];

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(SUBSCR, &subscr);

	ret_value.buf_addr = &retvaluebuff[0];
	ret_value.len_used = 0;
	ret_value.len_alloc = sizeof(retvaluebuff);

	printf("\n# Test that ydb_subscript_next_s() with nonexistent local variable with 1 subscript returns an empty string\n"); fflush(stdout);
	status = ydb_subscript_next_s(&basevar, 1, &subscr, &ret_value);
	if (YDB_OK != status)
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (ret_value.len_used == 0)
		{
			printf("ydb_subscript_next_s() returned an empty string\n");
			fflush(stdout);
		} else
		{
			printf("ydb_subscript_next_s() returned the wrong value: %s\n", ret_value.buf_addr);
			fflush(stdout);
		}

		if (YDB_ERR_NODEEND == status)
		{
			printf("ydb_subscript_next_s() returned YDB_ERR_NODEEND\n");
			fflush(stdout);
		} else
		{
			printf("ydb_subscript_next_s() returned the wrong value: %d\n", status);
			fflush(stdout);
		}
	}

	printf("\n# Test that ydb_subscript_previous_s() with nonexistent local variable with 1 subscript returns an empty string\n"); fflush(stdout);
	status = ydb_subscript_previous_s(&basevar, 1, &subscr, &ret_value);
	if (YDB_OK != status)
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (ret_value.len_used == 0)
		{
			printf("ydb_subscript_previous_s() returned an empty string\n");
			fflush(stdout);
		} else
		{
			printf("ydb_subscript_previous_s() returned the wrong value: %s\n", ret_value.buf_addr);
			fflush(stdout);
		}

		if (YDB_ERR_NODEEND == status)
		{
			printf("ydb_subscript_previous_s() returned YDB_ERR_NODEEND\n");
			fflush(stdout);
		} else
		{
			printf("ydb_subscript_previous_s() returned the wrong value: %d\n", status);
			fflush(stdout);
		}
	}

	printf("\n# Test that ydb_subscript_next_s() with nonexistent local variable with 0 subscripts returns an empty string\n"); fflush(stdout);
	status = ydb_subscript_next_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (ret_value.len_used == 0)
		{
			printf("ydb_subscript_next_s() returned an empty string\n");
			fflush(stdout);
		} else
		{
			printf("ydb_subscript_next_s() returned the wrong value: %s\n", ret_value.buf_addr);
			fflush(stdout);
		}

		if (YDB_ERR_NODEEND == status)
		{
			printf("ydb_subscript_next_s() returned YDB_ERR_NODEEND\n");
			fflush(stdout);
		} else
		{
			printf("ydb_subscript_next_s() returned the wrong value: %d\n", status);
			fflush(stdout);
		}
	}

	printf("\n# Test that ydb_subscript_previous_s() with nonexistent local variable with 0 subscripts returns an empty string\n"); fflush(stdout);
	status = ydb_subscript_previous_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (ret_value.len_used == 0)
		{
			printf("ydb_subscript_previous_s() returned an empty string\n");
			fflush(stdout);
		} else
		{
			printf("ydb_subscript_previous_s() returned the wrong value: %s\n", ret_value.buf_addr);
			fflush(stdout);
		}

		if (YDB_ERR_NODEEND == status)
		{
			printf("ydb_subscript_previous_s() returned YDB_ERR_NODEEND\n");
			fflush(stdout);
		} else
		{
			printf("ydb_subscript_previous_s() returned the wrong value: %d\n", status);
			fflush(stdout);
		}
	}
	return YDB_OK;
}
