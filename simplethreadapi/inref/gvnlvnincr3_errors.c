/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.	*
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

#define SUBSCR32	"subs"

#define SUBSCR1		"1"
#define INCR2		"2"
#define VALUE1		"9"

#define INCROF		"1E46"
#define VALUEOF		"9E46"

int main(int argc, char** argv)
{

	int 		status, copy_done, i;
	ydb_buffer_t 	ret_value, basevar, badvar1, badvar2, badvar3, subscr32[32], subscr1, incr2, value1, incrof, valueof, ofvar;
	char		errbuf[ERRBUF_SIZE], retvaluebuf[64], basevarbuf[64], badvarbuf1[64], badvarbuf2[64], badvarbuf3[64], ofvarbuf[64];

	printf("### Test error scenarios in ydb_incr_st() of %s Variables ###\n\n", argv[1]); fflush(stdout);
	/* Initialize varname and value buffers */
	basevar.buf_addr = &basevarbuf[0];
        basevar.len_used = 0;
	basevar.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[2], &basevar, copy_done);
	YDB_ASSERT(copy_done);
        basevar.buf_addr[basevar.len_used]='\0';

	badvar1.buf_addr = &badvarbuf1[0];
	badvar1.len_used = 0;
	badvar1.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[4], &badvar1, copy_done);
	YDB_ASSERT(copy_done);
	badvar1.buf_addr[badvar1.len_used]='\0';

	badvar2.buf_addr = &badvarbuf2[0];
	badvar2.len_used = 0;
	badvar2.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[5], &badvar2, copy_done);
	YDB_ASSERT(copy_done);
	badvar2.buf_addr[badvar2.len_used]='\0';

	badvar3.buf_addr = &badvarbuf3[0];
	badvar3.len_used = 0;
	badvar3.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[6], &badvar3, copy_done);
	YDB_ASSERT(copy_done);
	badvar3.buf_addr[badvar3.len_used]='\0';

	ofvar.buf_addr = &ofvarbuf[0];
	ofvar.len_used = 0;
	ofvar.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[3], &ofvar, copy_done);
	YDB_ASSERT(copy_done);
	ofvar.buf_addr[ofvar.len_used]='\0';

	ret_value.buf_addr = &retvaluebuf[0];
	ret_value.len_used = 0;
	ret_value.len_alloc = 64;

	YDB_LITERAL_TO_BUFFER(SUBSCR1, &subscr1);
	YDB_LITERAL_TO_BUFFER(INCR2, &incr2);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);
	YDB_LITERAL_TO_BUFFER(INCROF, &incrof);
	YDB_LITERAL_TO_BUFFER(VALUEOF, &valueof);

	printf("# Test of INVVARNAME error\n"); fflush(stdout);
	printf("# Attemping ydb_incr_st() of bad basevar (%% in middle of name): %s\n", badvar1.buf_addr); fflush(stdout);
	status = ydb_incr_st(YDB_NOTTP, NULL, &badvar1, 0, NULL, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attemping ydb_incr_st() of bad basevar (first letter in name is digit): %s\n", badvar2.buf_addr); fflush(stdout);
	status = ydb_incr_st(YDB_NOTTP, NULL, &badvar2, 0, NULL, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of VARNAME2LONG error\n"); fflush(stdout);
	printf("# Attemping ydb_incr_st() of bad basevar (> 31 characters): %s\n", badvar3.buf_addr); fflush(stdout);
	status = ydb_incr_st(YDB_NOTTP, NULL, &badvar3, 0, NULL, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of MAXNRSUBSCRIPTS error\n"); fflush(stdout);
	printf("# Attempting ydb_incr_st() of basevar with 32 subscripts\n"); fflush(stdout);
	for (i = 0; i < 32; i++)
		YDB_LITERAL_TO_BUFFER(SUBSCR32, &subscr32[i]);
	status = ydb_incr_st(YDB_NOTTP, NULL, &basevar, 32, subscr32, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of MINNRSUBSCRIPTS error\n"); fflush(stdout);
	printf("# Attemtpin ydb_incr_st() of basevar with -1 subscripts\n"); fflush(stdout);
	status = ydb_incr_st(YDB_NOTTP, NULL, &basevar, -1, NULL, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of INVSTRLEN error\n"); fflush(stdout);
	printf("# Set the variable %s to %s so it will increment from a 1 digit to 2 digits\n", basevar.buf_addr, value1.buf_addr); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_incr_st() when ret_value->len_alloc is insufficient\n"); fflush(stdout);
	ret_value.len_alloc = 1;
	status = ydb_incr_st(YDB_NOTTP, NULL, &basevar, 0, NULL, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of PARAMINVALID error\n"); fflush(stdout);
	printf("# Attempting ydb_incr_st() with *subsarray->len_alloc < *subsarray->len_used\n"); fflush(stdout);
	subscr1.len_used = subscr1.len_alloc + 1;
	status = ydb_incr_st(YDB_NOTTP, NULL, &basevar, 1, &subscr1, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	subscr1.len_used = 1;
	printf("# Attempting ydb_incr_st() with *increment->len_alloc < *increment->len_used\n"); fflush(stdout);
	incr2.len_used = incr2.len_alloc + 1;
	status = ydb_incr_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &incr2, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	incr2.len_used = 1;
	printf("# Attempting ydb_incr_st() with *subsarray->buf_addr set to NULL, and *subsarray->len_used is non-zero\n"); fflush(stdout);
	subscr1.buf_addr = NULL;
	status = ydb_incr_st(YDB_NOTTP, NULL, &basevar, 1, &subscr1, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_incr_st() with *increment->buf_addr set to NULL, and *increment->len_used is non-zero\n"); fflush(stdout);
	incr2.buf_addr = NULL;
	status = ydb_incr_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &incr2, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of NUMOFLOW error\n"); fflush(stdout);
	printf("# Set %s to %s\n", ofvar.buf_addr, valueof.buf_addr); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &ofvar, 0, NULL, &valueof);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_incr_st() on %s, incrementing by %s, resulting in a numerical overflow\n", ofvar.buf_addr, incrof.buf_addr);
	ret_value.len_used = 4;
	ret_value.len_alloc = 4;
	status = ydb_incr_st(YDB_NOTTP, NULL, &ofvar, 0, NULL, &incrof, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Get the value of %s to confirm is has not changed\n", ofvar.buf_addr); fflush(stdout);
	status = ydb_get_st(YDB_NOTTP, NULL, &ofvar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	} else if (memcmp(ret_value.buf_addr, VALUEOF, ret_value.len_used) == 0)
	{
		printf("The value of %s is unchanged\n", ofvar.buf_addr);
		fflush(stdout);
	} else
	{
		printf("Error: The value of %s was changed to %s\n", ofvar.buf_addr, ret_value.buf_addr);
		fflush(stdout);
	}
	printf("\n# Test of SUBSARRAYNULL error\n"); fflush(stdout);
	printf("# Attempting ydb_incr_st() with *subsarray = NULL\n"); fflush(stdout);
	status = ydb_incr_st(YDB_NOTTP, NULL, &basevar, 1, NULL, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	return YDB_OK;
}
