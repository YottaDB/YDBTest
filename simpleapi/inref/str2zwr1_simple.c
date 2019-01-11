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

#define STR_STRING	"X\0ABC"

int main()
{
	int 		status;
	ydb_buffer_t 	strstring, zwr_ret, str_ret;
	char		errbuf[ERRBUF_SIZE], retvaluebuf[64];

	printf("### Test of simple ydb_str2zwr_s() and ydb_zwr2str_s() ###\n"); fflush(stdout);
	/* Initialize varname, subscript, and value buffers */

	YDB_LITERAL_TO_BUFFER(STR_STRING, &strstring);

	zwr_ret.buf_addr = retvaluebuf;
	zwr_ret.len_alloc = sizeof(retvaluebuf);
	zwr_ret.len_used = 0;

	str_ret.buf_addr = retvaluebuf;
	str_ret.len_alloc = sizeof(retvaluebuf);
	str_ret.len_used = 0;

	printf("# Test ydb_str2zwr_s() using the string \"X\\0ABC\"\n"); fflush(stdout);
	status = ydb_str2zwr_s(&strstring, &zwr_ret);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_str2zwr_s(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else
	{
		printf("ydb_str2zwr_s() returns: %s\n", zwr_ret.buf_addr);
		fflush(stdout);
	}
	printf("# Test ydb_zwr2str_s() using the previous return value\n"); fflush(stdout);
	status = ydb_zwr2str_s(&zwr_ret, &str_ret);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_zwr2str_s(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (memcmp(str_ret.buf_addr, STR_STRING, 5) == 0)
	{
		printf("ydb_zwr2str_s() returned the original string.\n");
		fflush(stdout);
	}
	return YDB_OK;
}
