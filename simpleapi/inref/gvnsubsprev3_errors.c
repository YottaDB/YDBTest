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

#define BADBASEVAR1 "^B%dbasevarInvChar"
#define BADBASEVAR2 "^Verylongbasevarthatexceedsmaxlength"
#define BADBASEVAR3 "^1namestartswithdigit"
#define BASEVAR "^baselv"
#define NEXTVAR "^nextvar"
#define SUBSCR32 "x"
#define VALUE1	"A question"

int main()
{
	int		i, cnt, status;
	ydb_buffer_t	subscr32[32], badbasevar, basevar, nextvar, ret_value;
	ydb_buffer_t	save_subscr32, save_ret_value;
	char		errbuf[ERRBUF_SIZE];
	char		retvaluebuff[64];

	printf("### Test error scenarios in ydb_subscript_previous_s() of Global Variables ###\n"); fflush(stdout);
	/* Initialize varname and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(NEXTVAR, &nextvar);
	ret_value.buf_addr = retvaluebuff;
	ret_value.len_alloc = sizeof(retvaluebuff);
	ret_value.len_used = sizeof(VALUE1) - 1;
	memcpy(ret_value.buf_addr, VALUE1, ret_value.len_used);
	save_ret_value = ret_value;

	printf("\n# Test of INVVARNAME error\n"); fflush(stdout);
	printf("# Attempting ydb_subscript_previous_s() of bad basevar (%% in middle of name) %s\n", BADBASEVAR1);
	fflush(stdout);
	YDB_LITERAL_TO_BUFFER(BADBASEVAR1, &badbasevar);
	status = ydb_subscript_previous_s(&badbasevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_subscript_previous_s() of bad basevar (> 31 characters) %s\n", BADBASEVAR2);
	YDB_LITERAL_TO_BUFFER(BADBASEVAR2, &badbasevar);
	status = ydb_subscript_previous_s(&badbasevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_subscript_previous_s() of bad basevar (first letter in name is digit) %s\n", BADBASEVAR3);
	YDB_LITERAL_TO_BUFFER(BADBASEVAR3, &badbasevar);
	status = ydb_subscript_previous_s(&badbasevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of MAXNRSUBSCRIPTS error\n"); fflush(stdout);
	/* Now try getting > 31 subscripts */
	printf("# Attempting ydb_subscript_previous_s() of basevar with 32 subscripts\n");
	for (i = 0; i < 32; i++)
		YDB_LITERAL_TO_BUFFER(SUBSCR32, &subscr32[i]);
	status = ydb_subscript_previous_s(&basevar, 32, subscr32, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of MINNRSUBSCRIPTS error\n"); fflush(stdout);
	/* Now try getting < 0 subscripts */
	printf("# Attempting ydb_subscript_previous_s() of basevar with -1 subscripts\n");
	status = ydb_subscript_previous_s(&basevar, -1, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("\n# Test of PARAMINVALID error in ret_value parameter\n"); fflush(stdout);
	printf("# Attempting ydb_subscript_previous_s() with ret_value->buf_addr=NULL when return value is a NULL string : Expect NO PARAMINVALID error\n");
	status = ydb_set_s(&basevar, 0, NULL, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	ret_value.buf_addr = NULL;
	ret_value.len_used = getpid() % 2;	/* this value does not matter to the final error, hence the randomization */
	status = ydb_subscript_previous_s(&basevar, 0, NULL, &ret_value);
	if (YDB_ERR_NODEEND != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_subscript_previous_s() with NULL ret_value when return value is a NULL string : Expect PARAMINVALID error\n");
	status = ydb_subscript_previous_s(&basevar, 0, NULL, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_subscript_previous_s() with NULL ret_value when return value is a non-NULL string : Expect PARAMINVALID error\n");
	status = ydb_set_s(&basevar, 0, NULL, &save_ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	status = ydb_subscript_previous_s(&nextvar, 0, NULL, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Attempting ydb_subscript_previous_s() with ret_value->buf_addr=NULL when return value is a non-NULL string : Expect PARAMINVALID error\n");
	ret_value.buf_addr = NULL;
	ret_value.len_used = getpid() % 2;	/* this value does not matter to the final error, hence the randomization */
	status = ydb_subscript_previous_s(&nextvar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	ret_value = save_ret_value;
	printf("\n# Test of INVSTRLEN error\n"); fflush(stdout);
	printf("# Attempting ydb_subscript_previous_s() with ret_value->len_alloc=0 : Expect INVSTRLEN error\n");
	ret_value.len_alloc = 5;
	ret_value.len_used = getpid() % 2;	/* this value does not matter to the final error, hence the randomization */
	status = ydb_subscript_previous_s(&nextvar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s : ret_value->len_used = %d after call\n", __LINE__, errbuf, ret_value.len_used);
		fflush(stdout);
	}
	ret_value.len_alloc = ret_value.len_used;
	printf("# Attempting ydb_subscript_previous_s() with ret_value->len_alloc set to value returned in ret_value->len_used after INVSTRLEN error. Expect NO error\n");
	status = ydb_subscript_previous_s(&nextvar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	} else
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		printf("ydb_subscript_previous_s() returned [%s]\n", ret_value.buf_addr);
	}
	printf("\n# Test of SUBSARRAYNULL error\n"); fflush(stdout);
	printf("# Attempting ydb_subscript_previous_s() of basevar with NULL subsarray parameter. Expect SUBSARRAYNULL error\n");
	status = ydb_subscript_previous_s(&basevar, 1, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	ret_value = save_ret_value;	/* Restore ret_value to its good original value */
	printf("\n# Test of PARAMINVALID error in subsarray parameter\n"); fflush(stdout);
	for (i = 0, cnt = 0; cnt < 2; i = 3, cnt++)
	{
		printf("# Attempting ydb_subscript_previous_s() with subsarray[%d].len_alloc=0 and subsarray[%d].len_used=2 : Expect PARAMINVALID error\n", i, i);
		save_subscr32 = subscr32[i];
		subscr32[i].len_alloc = 0;
		subscr32[i].len_used = 2;
		status = ydb_subscript_previous_s(&basevar, 5, subscr32, &ret_value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		}
		printf("# Attempting ydb_subscript_previous_s() with subsarray[%d].len_alloc=0 and subsarray[%d].len_used=0 : Expect NO PARAMINVALID error\n", i, i);
		subscr32[i].len_alloc = 0;
		subscr32[i].len_used = 0;
		status = ydb_set_s(&basevar, 5, subscr32, &ret_value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s() [%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		}
		status = ydb_subscript_previous_s(&basevar, 5, subscr32, &ret_value);
		if (YDB_ERR_NODEEND != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		} else
			ret_value.len_used = 0;
		printf("# Attempting ydb_subscript_previous_s() with subsarray[%d].len_alloc=1 and subsarray[%d].len_used=0 : Expect NO PARAMINVALID error\n", i, i);
		subscr32[i].len_alloc = 1;
		subscr32[i].len_used = 0;
		status = ydb_set_s(&basevar, 5, subscr32, &ret_value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s() [%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		}
		status = ydb_subscript_previous_s(&basevar, 5, subscr32, &ret_value);
		if (YDB_ERR_NODEEND != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		} else
			ret_value.len_used = 0;
		printf("# Attempting ydb_subscript_previous_s() with subsarray[%d].len_alloc=1 and subsarray[%d].len_used=1 : Expect NO PARAMINVALID error\n", i, i);
		subscr32[i].len_alloc = 1;
		subscr32[i].len_used = 1;
		status = ydb_set_s(&basevar, 5, subscr32, &ret_value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s() [%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		}
		status = ydb_subscript_previous_s(&basevar, 5, subscr32, &ret_value);
		if (YDB_ERR_NODEEND != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		} else
			ret_value.len_used = 0;
		printf("# Attempting ydb_subscript_previous_s() with subscr32[%d].buf_addr=NULL and subscr32[%d].len_used=1 : Expect PARAMINVALID error\n", i, i);
		subscr32[i].buf_addr = NULL;
		subscr32[i].len_used = 1;
		status = ydb_subscript_previous_s(&basevar, 5, subscr32, &ret_value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		}
		printf("# Attempting ydb_subscript_previous_s() with subscr32[%d].buf_addr=NULL and subscr32[%d].len_used=0 : Expect NO PARAMINVALID error\n", i, i);
		subscr32[i].buf_addr = NULL;
		subscr32[i].len_used = 0;
		status = ydb_set_s(&basevar, 5, subscr32, &ret_value);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s() [%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		}
		status = ydb_subscript_previous_s(&basevar, 5, subscr32, &ret_value);
		if (YDB_ERR_NODEEND != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		} else
			ret_value.len_used = 0;
		subscr32[i] = save_subscr32;
	}
	printf("\n# Test that GVUNDEF error is NOT issued by ydb_subscript_previous_s()\n"); fflush(stdout);
	status = ydb_subscript_previous_s(&basevar, 2, subscr32, &ret_value);
	if (YDB_ERR_NODEEND == status)
		printf("ydb_subscript_previous_s() returned YDB_ERR_NODEEND\n");
	else if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_subscript_previous_s() [%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	} else
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		printf("ydb_subscript_previous_s() returned [%s]\n", ret_value.buf_addr);
	}
	printf("\n# Demonstrate our progress by executing a gvnZWRITE in a call-in\n"); fflush(stdout);
	status = ydb_ci("gvnZWRITE");
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("gvnZWRITE error [%d] : %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	return YDB_OK;
}
