/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC and/or its subsidiaries. 	*
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

#define BASEVAR		"basevar"

int main(void);

int tp_func();

int tp_func2();

int main(void)
{
	int			status;
	ydb_buffer_t		basevar, value;
	char			errbuf[ERRBUF_SIZE], valuebuff[64];
	ydb_tp2fnptr_t		tpfn;

	printf("### Test of YDB_ERR_INVTPTRANS error ###\n");
	fflush(stdout);

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);

	value.buf_addr = &valuebuff[0];
        value.len_used = 0;
        value.len_alloc = sizeof(valuebuff);

	tpfn = &tp_func;

	/* Initialize SimpleThreadAPI environment */
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("\n# Test Case 1: Call ydb_get_st() with tptoken = non-zero value (when a ydb_tp_st() has not already been done)\n"); fflush(stdout);
	status = ydb_get_st(1, NULL, &basevar, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}


	status = ydb_tp_st(YDB_NOTTP, NULL, tpfn, NULL, NULL, 0, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	return YDB_OK;
}

int tp_func(uint64_t tptoken, ydb_buffer_t *errstr, void *tpfnparm)
{
	int		status;
	ydb_buffer_t	basevar, value;
	char		errbuf[ERRBUF_SIZE], valuebuff[64];
	ydb_tp2fnptr_t		tpfn;

	tpfn = &tp_func2;

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);

	value.buf_addr = &valuebuff[0];
        value.len_used = 0;
        value.len_alloc = sizeof(valuebuff);

	printf("\n# Test Case 2: Call ydb_get_st() with tptoken = (1 << 56) | (0)\n"); fflush(stdout);
	printf("  Should issue INVTPTRANS error. This checks that low order 56 bits of 0 in tptoken issues an error.\n"); fflush(stdout);
	status = ydb_get_st(((uint64_t)1 << 56) | (0), NULL, &basevar, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("\n# Test Case 3: Call ydb_get_st() with tptoken = (1 << 56) | (3)\n"); fflush(stdout);
	printf("  Should issue INVTPTRANS error. Because expected lower order 56 bits is 2 but we are specifying 3.\n"); fflush(stdout);
	status = ydb_get_st(((uint64_t)1 << 56) | (3), NULL, &basevar, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("\n# Test Case 4: Call ydb_get_st() with tptoken = (1 << 56) | (2)\n"); fflush(stdout);
	printf("  Should issue INVTPTRANS error. Because expected lower order 56 bits is 3 but we are specifying 2.\n"); fflush(stdout);
	status = ydb_get_st(((uint64_t)1 << 56) | (2), NULL, &basevar, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("\n# Test Case 5: Call ydb_get_st() with tptoken = (0 << 56) | (4)\n"); fflush(stdout);
	printf("  Should issue INVTPTRANS error. This checks that high order 8 bits of 0 in tptoken issues an error.\n"); fflush(stdout);
	status = ydb_get_st(((uint64_t)0 << 56) | (4), NULL, &basevar, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("\n# Test Case 6: Call ydb_get_st() with tptoken = (2 << 56) | (5)\n"); fflush(stdout);
	printf("  Should issue INVTPTRANS error. Because expected high order 8 bits is 1 but we are specifying 2.\n"); fflush(stdout);
	status = ydb_get_st(((uint64_t)2 << 56) | (5), NULL, &basevar, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("\n# Test Case 7: Call ydb_tp_st() again to another callback function\n"); fflush(stdout);
	status = ydb_tp_st(tptoken, NULL, tpfn, NULL, NULL, 0, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}


	return YDB_OK;
}

int tp_func2(uint64_t tptoken, ydb_buffer_t *errstr, void *tpfnparm)
{
	int		status;
	ydb_buffer_t	basevar, value;
	char		errbuf[ERRBUF_SIZE], valuebuff[64];

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);

	value.buf_addr = &valuebuff[0];
        value.len_used = 0;
        value.len_alloc = sizeof(valuebuff);

	printf("# Call ydb_get_st() with tptoken = (3 << 56) | (6)\n"); fflush(stdout);
	printf("  Should issue INVTPTRANS error. Because expected high order 8 bits is 2 but we are specifying 3.\n"); fflush(stdout);
	status = ydb_get_st(((uint64_t)3 << 56) | (6), NULL, &basevar, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	return YDB_OK;
}
