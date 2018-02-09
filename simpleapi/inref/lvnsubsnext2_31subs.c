/****************************************************************
 *								*
 * Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.*
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
#define	MAX_SUBS	32

#define BASEVAR "baselv"
#define NEXTVAR "nextlv"

int main()
{
	int		status, subs, subs2;
	ydb_buffer_t	basevar, subsbuff[MAX_SUBS + 1], tmpsubs, ret_value;
	char		errbuf[ERRBUF_SIZE], subsstrlit[MAX_SUBS][3];	/* 3 to hold 2 digit decimal # + trailing null char */
	char		retvaluebuff[64];
	ydb_string_t	zwrarg;

	printf("### Test 31-level (max-deep) subscripts can be got using ydb_subscript_next_s() of Local Variables ###\n"); fflush(stdout);
	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	ret_value.buf_addr = retvaluebuff;
	ret_value.len_alloc = sizeof(retvaluebuff);
	ret_value.len_used = 0;
	for (subs = 0; subs < MAX_SUBS; subs++)
	{
		printf("Set a local variable (and next subscript) with %d subscripts\n", subs); fflush(stdout);
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
			YDB_LITERAL_TO_BUFFER(NEXTVAR, &basevar);
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
		if (0 == subs)
			basevar = tmpsubs;
		else
			subsbuff[subs2] = tmpsubs;
		status = ydb_subscript_next_s(&basevar, subs, subsbuff, &ret_value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_subscript_next_s() : subsbuff [%d]: %s\n", subs, errbuf);
			fflush(stdout);
			return YDB_OK;
		}
		ret_value.buf_addr[ret_value.len_used] = '\0';
		printf("ydb_subscript_next_s() : [level %d] returned [%s]\n", subs, ret_value.buf_addr);
	}
	printf("Demonstrate our progress by executing a ZWRITE in a call-in\n"); fflush(stdout);
	zwrarg.address = NULL;			/* Create a null string argument so dumps all locals */
	zwrarg.length = 0;
	status = ydb_ci("driveZWRITE", &zwrarg);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("driveZWRITE error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	return YDB_OK;
}
