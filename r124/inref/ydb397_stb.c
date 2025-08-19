/****************************************************************
 *								*
 * Copyright (c) 2018-2025 YottaDB LLC and/or its subsidiaries. *
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

#define BASEVAR "$basevar"
#define VALUE 	"value"

int main(void)
{
	int		status;
	ydb_buffer_t	basevar, value, ret_value;
	char		errbuf[ERRBUF_SIZE], basevarbuff[64], valuebuff[64], retvaluebuff[64];

	printf("\n# Testing SimpleThreadAPI function ydb_get_st() to ensure ZGBLDIRACC error does NOT occur\n");
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE, &value);

	ret_value.buf_addr = &retvaluebuff[0];
	ret_value.len_used = 0;
	ret_value.len_alloc = sizeof(retvaluebuff);

	printf("\n# Attempting ydb_get_st()\n");
	status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("[Line %d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	return YDB_OK;
}
