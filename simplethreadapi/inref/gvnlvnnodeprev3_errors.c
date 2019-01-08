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
#include <stdlib.h>
#include <sys/types.h>	/* needed for "getpid" */
#include <unistd.h>	/* needed for "getpid" */

#define ERRBUF_SIZE	1024

#define BADBASEVAR1 "^B%dbasevarInvChar"
#define BADBASEVAR2 "^Verylongbasevarthatexceedsmaxlength"
#define BADBASEVAR3 "^1namestartswithdigit"
#define VALUE	"test"
#define SUBSCR32 "subs"
#define NODE1	"1"
#define NODE2   "2"
#define empty	""

int main(int argc, char** argv)
{
	int		i, status, subs, copy_done;
	ydb_buffer_t	subscr32[32], badbasevar, basevar, nullvar, badvar1, badvar2, badvar3, emptyval, ret_value, node1, node2, value;
	ydb_buffer_t	bad_ret;
	char		errbuf[ERRBUF_SIZE];
	char		basevarbuff[64], nullvarbuff[64], badvarbuff1[64], badvarbuff2[64], badvarbuff3[64], retvaluebuff[64], bad_ret_buff[1];

	printf("### Test error scenarios in ydb_node_previous_st() of Global Variables ###\n\n"); fflush(stdout);
	/* Initialize varname and value buffers */
	basevar.buf_addr = &basevarbuff[0];
	basevar.len_used = 0;
	basevar.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[2], &basevar, copy_done);
	YDB_ASSERT(copy_done);
	basevar.buf_addr[basevar.len_used]='\0';

	nullvar.buf_addr = &nullvarbuff[0];
	nullvar.len_used = 0;
	nullvar.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[2], &nullvar, copy_done);
	YDB_ASSERT(copy_done);
	nullvar.buf_addr[nullvar.len_used]='\0';

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

	YDB_LITERAL_TO_BUFFER(empty, &emptyval);
	YDB_LITERAL_TO_BUFFER(NODE1, &node1);
	YDB_LITERAL_TO_BUFFER(NODE2, &node2);
	YDB_LITERAL_TO_BUFFER(VALUE, &value);

	ret_value.buf_addr = retvaluebuff;
	ret_value.len_alloc = sizeof(retvaluebuff);
	ret_value.len_used = sizeof(VALUE) - 1;

	bad_ret.buf_addr = bad_ret_buff;
	bad_ret.len_alloc = 0;
	bad_ret.len_used = 0;
	memcpy(ret_value.buf_addr, VALUE, ret_value.len_used);
	subs = 0;

	printf("# Test of INVVARNAME error\n"); fflush(stdout);
	printf("# Attempting ydb_node_previous_st() of bad basevar (%% in middle of name): %s\n", BADBASEVAR1);
	fflush(stdout);
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &badvar1, 0, NULL, &subs, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_node_previous_st() of bad basevar (first letter in name is digit): %s\n", BADBASEVAR3);
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &badvar2, 0, NULL, &subs, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of VARNAME2LONG error\n"); fflush(stdout);
	printf("# Attempting ydb_node_previous_st() of bad basevar (> 31 characters): %s\n", BADBASEVAR2);
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &badvar3, 0, NULL, &subs, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of MAXNRSUBSCRIPTS error\n"); fflush(stdout);
	/* Now try getting > 31 subscripts */
	printf("# Attempting ydb_node_previous_st() of basevar with 32 subscripts\n");
	for (i = 0; i < 32; i++)
		YDB_LITERAL_TO_BUFFER(SUBSCR32, &subscr32[i]);
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &basevar, 32, subscr32, &subs, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of MINNRSUBSCRIPTS error\n"); fflush(stdout);
	/* Now try getting < 0 subscripts */
	printf("# Attempting ydb_node_previous_st() of basevar with -1 subscripts\n");
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &basevar, -1, NULL, &subs, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("\n# Test of INSUFFSUBS error\n"); fflush(stdout);
	printf("# Attempting ydb_node_previous_st() with *ret_subs_used=0 : Expect INSUFFSUBS error\n"); fflush(stdout);
	/* Set 2 more nodes with, both with a subscript of 1 */
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar,1,&node1,&value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar,1,&node2,&value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	subs = 0;
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &basevar,1,&node2,&subs,&ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("\n# Test of INVSTRLEN\n"); fflush(stdout);
	printf("# Attempting ydb_node_previous_st() with ret_sub_array[0]:len_alloc set to 0 whereas return value is of length 1 : Expect INVSTRLEN error\n"); fflush(stdout);
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &basevar,1,&node2,&subs,&bad_ret);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of PARAMINVALID error in ret_subarray parameter\n"); fflush(stdout);
	printf("# Attempting ydb_node_previous_st() with ret_subarray->buf_addr = NULL : Expect PARAMINVALID error\n");
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	ret_value.buf_addr = NULL;
	ret_value.len_used = getpid() % 2;	/* this value does not matter to the final error, hence the randomization */
	subs = 1;
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &basevar, 1, &node2, &subs, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_node_previous_st() with *ret_subarray = NULL : Expect PARAMINVALID error\n"); fflush(stdout);
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &basevar, 1, &node2, &subs, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_node_previous_st() with ret_subs_used = NULL : Expect PARAMINVALID error\n"); fflush(stdout);
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &basevar, 0, NULL, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_node_previous_st() with the previous node subscript = \"\" and ret_value->buf_addr = NULL : Expect NO PARAMINVALID error\n");
	fflush(stdout);
	subs = 1;
	printf("Set %s variable to null string: ", argv[2]); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &nullvar, 0, &emptyval, &value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("%s(%s) set to %s\n", nullvar.buf_addr, emptyval.buf_addr, value.buf_addr); fflush(stdout);
	ret_value.buf_addr = NULL;
	ret_value.len_used = 0;
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &nullvar, 1, &node1, &subs, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	if (ret_value.len_used == 0)
	{
		printf("ydb_node_previous_st() returns %s(\"\")\n", nullvar.buf_addr);
		fflush(stdout);
	}
	subs = 1;
	printf("\n# Test of SUBSARRAYNULL error\n"); fflush(stdout);
	printf("# Attempting ydb_node_previous_st() with *subsarray = NULL : Expect SUBSARRAYNULL error\n"); fflush(stdout);
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &basevar, 1, NULL, &subs, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	return YDB_OK;
}
