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
#include <sys/types.h>	/* needed for "getpid" */
#include <unistd.h>	/* needed for "getpid" */
#include <string.h>	/* needed for "memcpy" */

#define ERRBUF_SIZE	1024

#define SUBSCR32	"subs"
#define SUBSCR1		"1"
#define VALUE		"test"

int main(int argc, char** argv)
{
	int 		status, copy_done, i;
	ydb_buffer_t 	basevar, badvar1, badvar2, badvar3, value, subscr1, subscr32[32];
	char 		errbuf[ERRBUF_SIZE], basevarbuf[64], badvarbuf1[64], badvarbuf2[64], badvarbuf3[64];


	printf("### Test error scenarios in ydb_delete_s() of %s Variables ###\n\n", argv[1]); fflush(stdout);
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

	YDB_LITERAL_TO_BUFFER(VALUE, &value);
	YDB_LITERAL_TO_BUFFER(SUBSCR1, &subscr1);
	status = ydb_set_s(&basevar, 0, NULL, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Test of INVVARNAME error\n"); fflush(stdout);
	printf("# Attemping ydb_delete_s() of bad basevar (%% in middle of name): %s\n", badvar1.buf_addr); fflush(stdout);
	status = ydb_delete_s(&badvar1, 0, NULL, YDB_DEL_NODE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attemping ydb_delete_s() of bad basevar (first letter in name is digit): %s\n", badvar2.buf_addr); fflush(stdout);
	status = ydb_delete_s(&badvar2, 0, NULL, YDB_DEL_NODE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of VARNAME2LONG error\n"); fflush(stdout);
	printf("# Attemping ydb_delete_s() of bad basevar (> 31 characters): %s\n", badvar3.buf_addr); fflush(stdout);
	status = ydb_delete_s(&badvar3, 0, NULL, YDB_DEL_NODE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of MAXNRSUBSCRIPTS error\n"); fflush(stdout);
	printf("# Attempting ydb_delete_s() of basevar with 32 subscripts\n"); fflush(stdout);
	for (i = 0; i < 32; i++)
		YDB_LITERAL_TO_BUFFER(SUBSCR32, &subscr32[i]);
	status = ydb_delete_s(&basevar, 32, subscr32, YDB_DEL_NODE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of MINNRSUBSCRIPTS error\n"); fflush(stdout);
	printf("# Attempting ydb_delete_s() of basevar with -1 subscripts\n"); fflush(stdout);
	status = ydb_delete_s(&basevar, -1, NULL, YDB_DEL_NODE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of UNIMPLOP error\n"); fflush(stdout);
	printf("# Attempting ydb_delete_s() with deltype != YDB_DEL_NODE/YDB_DEL_TREE\n"); fflush(stdout);
	status = ydb_delete_s(&basevar, 0, NULL, YDB_DEL_NODE+100);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of PARAMINVALID error\n"); fflush(stdout);
	printf("# Attempting ydb_delete_s() with *subsarray->len_alloc < *subsarray->len_used\n"); fflush(stdout);
	subscr1.len_used = subscr1.len_alloc + 1;
	status = ydb_delete_s(&basevar, 1, &subscr1, YDB_DEL_NODE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	subscr1.len_used = 1;
	printf("# Attempting ydb_delete_s() with *subsarray->buf_addr set to NULL, and *subsarray->len_used is non-zero\n"); fflush(stdout);
	subscr1.buf_addr = NULL;
	status = ydb_delete_s(&basevar, 1, &subscr1, YDB_DEL_NODE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of SUBSARRAYNULL error\n"); fflush(stdout);
	printf("# Attempting ydb_delete_s() with *subsarray = NULL\n"); fflush(stdout);
	status = ydb_delete_s(&basevar, 1, NULL, YDB_DEL_NODE);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_delete_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	return YDB_OK;
}
