/****************************************************************
*								*
* Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	*
* All rights reserved.						*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
/* This file is used by the ydb518 test to create a shared library
 * for testing external calls involving the ydb_int64_t and
 * ydb_uint64_t types. */

#include <string.h>
#include "gtm_stdio.h"

#include "shrenv.h"
#include "libyottadb.h"

ydb_int64_t squarec(int count, ydb_int64_t val)
{
	ydb_int64_t	cube;
	char		err[500];

	fflush(stdout);
	PRINTF("\nC2, C-> M -> C -> M\n");
	PRINTF("val = %ld\n", val);
	PRINTF("Using squarec.c (int64) The square of %ld is %ld\n", val, val * val);
	if (ydb_ci("cube", &cube, val))
	{
		ydb_zstatus(&err[0], 500);
		PRINTF(" %s \n", err);
		fflush(stdout);
	}
	PRINTF("Call into cubeit^cube for int64 returns the cube of %ld as %ld\n", val, cube);
	fflush(stdout);
	return val * val;
}

ydb_uint64_t usquarec(int count, ydb_uint64_t val)
{
	ydb_uint64_t	cube;
	char		err[500];

	fflush(stdout);
	PRINTF("\nC2, C-> M -> C -> M\n");
	PRINTF("val = %lu\n", val);
	PRINTF("Using squarec.c (uint64) The square of %lu is %lu\n", val, val * val);
	if (ydb_ci("cube", &cube, val))
	{
		ydb_zstatus(&err[0], 500);
		PRINTF(" %s \n", err);
		fflush(stdout);
	}
	PRINTF("Call into cubeit^cube for uint64 returns the cube of %lu as %lu\n", val, cube);
	fflush(stdout);
	return val * val;
}
