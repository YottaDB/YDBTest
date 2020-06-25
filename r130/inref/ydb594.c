/****************************************************************
 *								*
 * Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.      *
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

#define	FLOAT		((float)1.234567)
#define	LEN_ALLOC	10

int main()
{
	ydb_buffer_t	basevar, value;
	ydb_buffer_t	incr;
	int		i, status;

	YDB_LITERAL_TO_BUFFER("baselv", &basevar);
	/* Do ydb_incr_s() with a floating number such that YottaDB treats it as an MV_NM (not an MV_INT) */
	printf("Do ydb_incr_s() : [baselv=%f]\n", FLOAT);
	incr.buf_addr = ydb_malloc(LEN_ALLOC);
	incr.len_used = sprintf(incr.buf_addr, "%f", FLOAT);
	incr.len_alloc = LEN_ALLOC;
	status = ydb_incr_s(&basevar, 0, NULL, &incr, NULL);
	ydb_free(incr.buf_addr);
	/* Do ydb_get_s() to verify we get the same thing back */
	value.buf_addr = ydb_malloc(LEN_ALLOC);
	value.len_alloc = LEN_ALLOC;
	status = ydb_get_s(&basevar, 0, NULL, &value);
	value.buf_addr[value.len_used] = '\0';
	printf("do ydb_get_s(baselv) : Expected = %f : Actual = %s\n", FLOAT, value.buf_addr);
	return status;
}

