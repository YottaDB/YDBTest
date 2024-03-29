/****************************************************************
 *								*
 * Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries. *
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

#define BADBASEVAR1 "^B%dbasevarInvChar"
#define BADBASEVAR2 "^Verylongbasevarthatexceedsmaxlength"
#define BADBASEVAR3 "^1namestartswithdigit"
#define BASEVAR "^baselv"
#define SUBSCR32 "x"
#define VALUE1	"A question"

int main()
{
	int		i, cnt, status;
	ydb_buffer_t	subscr32[32], value1, badbasevar, basevar;
	ydb_buffer_t	save_subscr32, save_value1;
	char		errbuf[ERRBUF_SIZE];

	printf("### Test error scenarios in ydb_set_st() of Global Variables ###\n\n"); fflush(stdout);
	/* Initialize varname and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);
	save_value1 = value1;

	printf("# Test of INVVARNAME error\n"); fflush(stdout);
	printf("Attempting set of bad basevar (%% in middle of name) %s\n", BADBASEVAR1);
	fflush(stdout);
	YDB_LITERAL_TO_BUFFER(BADBASEVAR1, &badbasevar);
	status = ydb_set_st(YDB_NOTTP, NULL, &badbasevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [a]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Attempting set of bad basevar (> 31 characters) %s\n", BADBASEVAR2);
	YDB_LITERAL_TO_BUFFER(BADBASEVAR2, &badbasevar);
	status = ydb_set_st(YDB_NOTTP, NULL, &badbasevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [b]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Attempting set of bad basevar (first letter in name is digit) %s\n", BADBASEVAR3);
	YDB_LITERAL_TO_BUFFER(BADBASEVAR3, &badbasevar);
	status = ydb_set_st(YDB_NOTTP, NULL, &badbasevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [c]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("# Test of MAXNRSUBSCRIPTS error\n"); fflush(stdout);
	/* Now try setting > 31 subscripts */
	printf("Attempting set of basevar with 32 subscripts\n");
	for (i = 0; i < 32; i++)
		YDB_LITERAL_TO_BUFFER(SUBSCR32, &subscr32[i]);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 32, subscr32, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [d]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("# Test of MINNRSUBSCRIPTS error\n"); fflush(stdout);
	/* Now try setting < 0 subscripts */
	printf("Attempting set of basevar with -1 subscripts\n");
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, -1, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [e]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("# Test of PARAMINVALID error in value parameter\n"); fflush(stdout);
	printf("Attempting set with value->len_alloc=0 and value->len_used=1 : Expect PARAMINVALID error\n");
	value1.len_alloc = 0;
	value1.len_used = 1;
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [f]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Attempting set with value->len_alloc=0 and value->len_used=0 : Expect NO PARAMINVALID error\n");
	value1.len_alloc = 0;
	value1.len_used = 0;
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [g]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Attempting set with value->len_alloc=1 and value->len_used=0 : Expect NO PARAMINVALID error\n");
	value1.len_alloc = 1;
	value1.len_used = 0;
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [h]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Attempting set with value->len_alloc=1 and value->len_used=1 : Expect NO PARAMINVALID error\n");
	value1.len_alloc = 1;
	value1.len_used = 1;
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [i]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Attempting set with value->buf_addr=NULL and value->len_used=1 : Expect PARAMINVALID error\n");
	value1.buf_addr = NULL;
	value1.len_used = 1;
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [j]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Attempting set with value->buf_addr=NULL and value->len_used=0 : Expect NO PARAMINVALID error\n");
	value1 = save_value1;	/* Restore value1 to its good original value */
	value1.buf_addr = NULL;
	value1.len_used = 0;
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [k]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("# Test of SUBSARRAYNULL error\n"); fflush(stdout);
	printf("Attempting set of basevar with NULL subsarray parameter. Expect SUBSARRAYNULL error\n");
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 1, NULL, &value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [l]: %s\n", errbuf);
		fflush(stdout);
	}
	value1 = save_value1;	/* Restore value1 to its good original value */
	printf("# Test of PARAMINVALID error in subsarray parameter\n"); fflush(stdout);
	for (i = 0, cnt = 0; cnt < 2; i = 3, cnt++)
	{
		printf("Attempting set with subsarray[%d].len_alloc=0 and subsarray[%d].len_used=2 : Expect PARAMINVALID error\n", i, i);
		save_subscr32 = subscr32[i];
		subscr32[i].len_alloc = 0;
		subscr32[i].len_used = 2;
		status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 5, subscr32, &value1);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_st() [m]: %s\n", errbuf);
			fflush(stdout);
		}
		printf("Attempting set with subsarray[%d].len_alloc=0 and subsarray[%d].len_used=0 : Expect NO PARAMINVALID error\n", i, i);
		subscr32[i].len_alloc = 0;
		subscr32[i].len_used = 0;
		status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 5, subscr32, &value1);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_st() [n]: %s\n", errbuf);
			fflush(stdout);
		}
		printf("Attempting set with subsarray[%d].len_alloc=1 and subsarray[%d].len_used=0 : Expect NO PARAMINVALID error\n", i, i);
		subscr32[i].len_alloc = 1;
		subscr32[i].len_used = 0;
		status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 5, subscr32, &value1);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_st() [o]: %s\n", errbuf);
			fflush(stdout);
		}
		printf("Attempting set with subsarray[%d].len_alloc=1 and subsarray[%d].len_used=1 : Expect NO PARAMINVALID error\n", i, i);
		subscr32[i].len_alloc = 1;
		subscr32[i].len_used = 1;
		status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 5, subscr32, &value1);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_st() [p]: %s\n", errbuf);
			fflush(stdout);
		}
		printf("Attempting set with subscr32[%d].buf_addr=NULL and subscr32[%d].len_used=1 : Expect PARAMINVALID error\n", i, i);
		subscr32[i].buf_addr = NULL;
		subscr32[i].len_used = 1;
		status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 5, subscr32, &value1);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_st() [q]: %s\n", errbuf);
			fflush(stdout);
		}
		printf("Attempting set with subscr32[%d].buf_addr=NULL and subscr32[%d].len_used=0 : Expect NO PARAMINVALID error\n", i, i);
		subscr32[i].buf_addr = NULL;
		subscr32[i].len_used = 0;
		status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 5, subscr32, &value1);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_st() [r]: %s\n", errbuf);
			fflush(stdout);
		}
		subscr32[i] = save_subscr32;
	}
	printf("# Demonstrate our progress by executing a gvnZWRITE in a call-in\n"); fflush(stdout);
	status = ydb_ci_t(YDB_NOTTP, NULL, "gvnZWRITE");
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("gvnZWRITE error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Test of ISVSUBSCRIPTED error\n"); fflush(stdout);
	ydb_buffer_t	isvvar, ret_value;
	YDB_LITERAL_TO_BUFFER("$ztrap", &isvvar);
	status = ydb_set_st(YDB_NOTTP, NULL, &isvvar, 1, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	return YDB_OK;
}
