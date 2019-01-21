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
#include <string.h>

#define ERRBUF_SIZE	1024
#define	MAX_SUBS	32

#define BASEVAR "^baselv"
#define PREVVAR "^aprevlv"

int main()
{
	int		status, subs, subs2, ret_test;
	ydb_buffer_t	basevar, prevvar, subsbuff[MAX_SUBS + 1], tmpsubs, ret_value;
	char		errbuf[ERRBUF_SIZE], subsstrlit[MAX_SUBS][3];	/* 3 to hold 2 digit decimal # + trailing null char */
	char		retvaluebuff[64], rettestbuff[64];

	printf("### Test 31-level (max-deep) subscripts can be got using ydb_subscript_previous_s() of Global Variables ###\n\n"); fflush(stdout);
	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(PREVVAR, &prevvar);
	ret_value.buf_addr = retvaluebuff;
	ret_value.len_alloc = sizeof(retvaluebuff);
	ret_value.len_used = 0;
	for (subs = 0; subs < MAX_SUBS; subs++)
	{
		printf("# Set a global variable (and prev subscript) with %d subscripts\n", subs); fflush(stdout);
		subsbuff[subs].len_used = subsbuff[subs].len_alloc = sprintf(subsstrlit[subs], "%d", subs);
		subsbuff[subs].buf_addr = subsstrlit[subs];
		if (subs % 2)
			status = ydb_set_s(&basevar, subs, subsbuff, &subsbuff[subs]);
		else
			status = ydb_set_s(&basevar, subs, subsbuff, NULL);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s() [1] : subsbuff [%d]: %s\n", subs, errbuf);
			fflush(stdout);
			return YDB_OK;
		}
		if (0 == subs)
		{
			tmpsubs = basevar;
			YDB_LITERAL_TO_BUFFER(PREVVAR, &basevar);
		} else
		{
			subs2 = subs - 1;
			tmpsubs = subsbuff[subs2];
			subsbuff[subs2] = subsbuff[subs];
		}
		status = ydb_set_s(&basevar, subs, subsbuff, &subsbuff[subs]);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s() [2] : subsbuff [%d]: %s\n", subs, errbuf);
			fflush(stdout);
			return YDB_OK;
		}
		status = ydb_subscript_previous_s(&basevar, subs, subsbuff, &ret_value);
		if (YDB_ERR_NODEEND == status)
			ret_value.len_used = 0;
		else if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_subscript_previous_s() : subsbuff [%d]: %s\n", subs, errbuf);
			fflush(stdout);
			return YDB_OK;
		}
		if (0 == subs)
			basevar = tmpsubs;
		else
			subsbuff[subs2] = tmpsubs;
		ret_value.buf_addr[ret_value.len_used] = '\0';
		printf("ydb_subscript_previous_s() : [level %d] returned [%s]\n", subs, ret_value.buf_addr);

		printf("# Get prev global variable of global variable with %d subscripts\n", subs); fflush(stdout);
		ret_test = ret_value.len_used;
		memcpy(rettestbuff, ret_value.buf_addr, ret_value.len_used);
		status = ydb_subscript_previous_s(&prevvar, subs, subsbuff, &ret_value);
		if (YDB_ERR_NODEEND != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_subscript_next_s() did not return YDB_ERR_NODEEND: %s\n", errbuf);
			fflush(stdout);
			return YDB_OK;
		} else if (ret_value.len_used != ret_test || memcmp(rettestbuff, ret_value.buf_addr, ret_value.len_used) != 0)
		{
			printf("ydb_subscript_next_s(): *ret_value was altered\n");
			fflush(stdout);
		} else
		{
			printf("ydb_subscript_next_s() returned YDB_ERR_NODEEND\n");
			printf("*ret_value.len_used and ret_value.buf_addr were unaltered.\n");
			fflush(stdout);
		}
	}
	printf("\n# Demonstrate our progress by executing a gvnZWRITE in a call-in\n"); fflush(stdout);
	status = ydb_ci("gvnZWRITE");
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("gvnZWRITE error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	return YDB_OK;
}
