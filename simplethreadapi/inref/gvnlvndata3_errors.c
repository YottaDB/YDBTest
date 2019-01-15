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
#include <sys/types.h>	/* needed for "getpid" */
#include <unistd.h>	/* needed for "getpid" */
#include <string.h>	/* needed for "memcpy" */

#define ERRBUF_SIZE	1024

#define SUBSCR32 	"subs"
#define VALUE		"test"
#define NODE1		"1"
#define SUBSCR1		"1"
#define null 		""

int main(int argc, char** argv)
{
	unsigned int	i, cnt, status, copy_done, ret_value;
	ydb_buffer_t	subscr32[32], badbasevar, basevar, badvar1, badvar2, badvar3, node1, value, subscr1;
	char		errbuf[ERRBUF_SIZE];
	char		retvaluebuff[64], basevarbuff[64], badvarbuff1[64], badvarbuff2[64], badvarbuff3[64];

	printf("### Test error scenarios in ydb_data_st() of %s Variables ###\n", argv[1]); fflush(stdout);
	/* Initialize varname and value buffers */
	basevar.buf_addr = &basevarbuff[0];
        basevar.len_used = 0;
	basevar.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[2], &basevar, copy_done);
	YDB_ASSERT(copy_done);
        basevar.buf_addr[basevar.len_used]='\0';

	badvar1.buf_addr = &badvarbuff1[0];
	badvar1.len_used = 0;
	badvar1.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[4], &badvar1, copy_done);
	YDB_ASSERT(copy_done);
	badvar1.buf_addr[badvar1.len_used]='\0';

	badvar2.buf_addr = &badvarbuff2[0];
	badvar2.len_used = 0;
	badvar2.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[5], &badvar2, copy_done);
	YDB_ASSERT(copy_done);
	badvar2.buf_addr[badvar2.len_used]='\0';

	badvar3.buf_addr = &badvarbuff3[0];
	badvar3.len_used = 0;
	badvar3.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[6], &badvar3, copy_done);
	YDB_ASSERT(copy_done);
	badvar3.buf_addr[badvar3.len_used]='\0';

	YDB_LITERAL_TO_BUFFER(NODE1, &node1);
	YDB_LITERAL_TO_BUFFER(VALUE, &value);
	YDB_LITERAL_TO_BUFFER(SUBSCR1, &subscr1);

	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 1, &node1, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of INVVARNAME error\n"); fflush(stdout);
	printf("# Attemping ydb_data_st() of bad basevar (%% in middle of name): %s\n", badvar1.buf_addr); fflush(stdout);
	status = ydb_data_st(YDB_NOTTP, NULL, &badvar1, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attemping ydb_data_st() of bad basevar (first letter in name is digit): %s\n", badvar2.buf_addr); fflush(stdout);
	status = ydb_data_st(YDB_NOTTP, NULL, &badvar2, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of VARNAME2LONG error\n"); fflush(stdout);
	printf("# Attemping ydb_data_st() of bad basevar (> 31 characters): %s\n", badvar3.buf_addr); fflush(stdout);
	status = ydb_data_st(YDB_NOTTP, NULL, &badvar3, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of MAXNRSUBSCRIPTS error\n"); fflush(stdout);
	printf("# Attempting ydb_data_st() of basevar with 32 subscripts\n"); fflush(stdout);
	for (i = 0; i < 32; i++)
		YDB_LITERAL_TO_BUFFER(SUBSCR32, &subscr32[i]);
	status = ydb_data_st(YDB_NOTTP, NULL, &basevar, 32, subscr32, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of MINNRSUBSCRIPTS error\n"); fflush(stdout);
	printf("# Attemtpin ydb_data_st() of basevar with -1 subscripts\n"); fflush(stdout);
	status = ydb_data_st(YDB_NOTTP, NULL, &basevar, -1, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of PARAMINVALID error\n"); fflush(stdout);
	printf("# Attempting ydb_data_st() with ret_value = NULL : Expect PARAMINVALID error\n"); fflush(stdout);
	status = ydb_data_st(YDB_NOTTP, NULL, &basevar, 0, NULL, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_data_st() with *subsarray->len_alloc < *subsarray->len_used\n"); fflush(stdout);
	subscr1.len_used = subscr1.len_alloc + 1;
	status = ydb_data_st(YDB_NOTTP, NULL, &basevar, 1, &subscr1, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	subscr1.len_used = 1;
	printf("# Attempting ydb_incr_st() with *subsarray->buf_addr set to NULL, and *subsarray->len_used is non-zero\n"); fflush(stdout);
	subscr1.buf_addr = NULL;
	status = ydb_data_st(YDB_NOTTP, NULL, &basevar, 1, &subscr1, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of SUBSARRAYNULL error\n"); fflush(stdout);
	printf("# Attempting ydb_data_st() with *subarray = NULL : Expect SUBSARRAYNULL error\n"); fflush(stdout);
	status = ydb_data_st(YDB_NOTTP, NULL, &basevar, 1, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	return YDB_OK;
}
