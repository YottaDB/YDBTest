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
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <time.h>


#define ERRBUF_SIZE	1024

#define NODE1		"1"
#define NODE2		"2"
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

int main(int argc, char** argv)
{
	int		status, copy_done;
	ydb_buffer_t	basevar, node1, node12[2], node2, value, ret_value;
	char		errbuf[ERRBUF_SIZE], basevarbuf[64], retvaluebuf[64];

	YDB_LITERAL_TO_BUFFER(NODE1, &node1);
	YDB_LITERAL_TO_BUFFER(NODE1, &node12[0]);
	YDB_LITERAL_TO_BUFFER(NODE2, &node12[1]);
	YDB_LITERAL_TO_BUFFER(NODE2, &node2);
	YDB_LITERAL_TO_BUFFER(VALUE, &value);

	basevar.buf_addr = &basevarbuf[0];
	basevar.len_used = 0;
	basevar.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[2], &basevar, copy_done);
	YDB_ASSERT(copy_done);
	basevar.buf_addr[basevar.len_used]='\0';

	ret_value.buf_addr = retvaluebuf;
	ret_value.len_alloc = sizeof(retvaluebuf);
	ret_value.len_used = 0;

	printf("### Test simple ydb_delete_st() of %s Variables ###\n", argv[1]); fflush(stdout);
	printf("# Set %s tree nodes to %s\n", basevar.buf_addr, VALUE);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(YDB_NOTTP, NULL, ): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 1, &node1, &value);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(YDB_NOTTP, NULL, ): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 2, node12, &value);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(YDB_NOTTP, NULL, ): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	printf("\n# Test ydb_delete_st() on %s(1,2) with deltype = YDB_DEL_NODE\n", basevar.buf_addr); fflush(stdout);
	status = ydb_delete_st(YDB_NOTTP, NULL, &basevar, 2, node12, YDB_DEL_NODE);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_st() error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	printf("# Reset the value at %s(1,2)\n", basevar.buf_addr); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 2, node12, &value);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(YDB_NOTTP, NULL, ): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("\n# Test ydb_delete_st() on %s with deltype = YDB_DEL_NODE\n", basevar.buf_addr); fflush(stdout);
	status = ydb_delete_st(YDB_NOTTP, NULL, &basevar, 0, NULL, YDB_DEL_NODE);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_st() error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	printf("# Reset the value at %s\n", basevar.buf_addr); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(YDB_NOTTP, NULL, ): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("\n# Test ydb_delete_st() on %s with deltype = YDB_DEL_TREE : This should delete all child nodes as well\n", basevar.buf_addr); fflush(stdout);
	status = ydb_delete_st(YDB_NOTTP, NULL, &basevar, 0, NULL, YDB_DEL_TREE);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_st() error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	printf("# Reset the deleted nodes\n"); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(YDB_NOTTP, NULL, ): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 1, &node1, &value);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(YDB_NOTTP, NULL, ): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 2, node12, &value);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(YDB_NOTTP, NULL, ): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("\n# Set variable %s(2) to %s\n", basevar.buf_addr, value.buf_addr); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 1, &node2, &value);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(YDB_NOTTP, NULL, ): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	printf("\n# Test ydb_delete_st() on %s(1) with deltype = YDB_DEL_TREE : This should not affect %s or %s(2)\n", basevar.buf_addr, basevar.buf_addr, basevar.buf_addr); fflush(stdout);
	status = ydb_delete_st(YDB_NOTTP, NULL, &basevar, 1, &node1, YDB_DEL_TREE);
	if (status != YDB_OK)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_st() error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Print the current tree\n"); fflush(stdout);
	ZWrite( argv[1] );
	return YDB_OK;
}
