/****************************************************************
 *								*
 * Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	*
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
#define	LOCK_TIMEOUT	(unsigned long long)100000000000	/* 100 * 10^9 nanoseconds == 100 seconds */

/* Test PARAMINVALID and INVVARNAME errors from an invalid varname parameter in various Simple Thread API calls */
int main()
{
        ydb_buffer_t    basevar;
        int             status;
	char		varname[5];
	ydb_buffer_t	basevarname1, basevarname2;
	char		errbuf[ERRBUF_SIZE];

	printf("# Test control characters get displayed using $ZWRITE notation in INVVARNAME error\n");
	varname[0] = 'a';
	varname[1] = 'b';
	varname[2] = (char)3;
	varname[3] = 'd';
	varname[4] = '\0';
	basevar.buf_addr = varname;
	basevar.len_alloc = basevar.len_used = 4;
        status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 0, NULL, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	printf("\n");

	printf("# Test PARAMINVALID error is issued if varname ydb_buffer_t.len_alloc is less than ydb_buffer_t.len_used\n");
	printf("# Also test that PARAMINVALID error correctly identified ydb_get_st() as the caller function\n");
	basevar.len_alloc = basevar.len_used - 1;
        status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 0, NULL, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	basevar.len_alloc = basevar.len_used;	/* restore "len_alloc" before moving on to next stage of test */
	printf("\n");

	printf("# Test PARAMINVALID error is issued if varname ydb_buffer_t.buf_addr is NULL and ydb_buffer_t.len_used is not 0\n");
	printf("# Also test that PARAMINVALID error correctly identified ydb_get_st() as the caller function\n");
	basevar.buf_addr = NULL;
        status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 0, NULL, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	basevar.buf_addr = varname;	/* restore "buf_addr" before moving on to next stage of test */
	printf("\n");

	printf("# Test INVVARNAME error is issued if ydb_buffer_t.len_used is 0\n");
	basevar.len_used = 0;
        status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 0, NULL, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	basevar.len_used = basevar.len_alloc;	/* restore "len_used" before moving on to next stage of test */
	printf("\n");

	printf("# Test ydb_lock_st() with multiple lock names one of which is invalid identifies the invalid name\n");
	YDB_LITERAL_TO_BUFFER("lockA", &basevarname1);
	YDB_LITERAL_TO_BUFFER("1lockB", &basevarname2);
	status = ydb_lock_st(YDB_NOTTP, NULL, LOCK_TIMEOUT, 2, &basevarname1, 0, NULL, &basevarname2, 0, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	printf("\n");
        return 0;
}
