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
/* This tests call ins and external calls involving the new ydb_int64_t and ydb_uint64_t types to make
 * sure that the new types work correctly.
 */
#include <string.h>
#include "gtm_stdio.h"

#include "libyottadb.h"

int main()
{
	ydb_status_t	status;
	char		err[500];
	ydb_int64_t	num, root;
	ydb_uint64_t	unum, uroot;

	/* This number is the square of 5000. The cube of 5000 is 125 billion which won't fit in a 32 bit int */
	num = 25000000;
	root = 2;
	unum = 25000000;
	uroot = 2;

	status = ydb_init();
	if (status)
	{
		ydb_zstatus(&err[0], 500);
		PRINTF(" %s\n", err);
	}
	status = ydb_ci("sqroot", num, root);
	if (status)
	{
		ydb_zstatus(&err[0], 500);
		PRINTF(" %s\n", err);
	}
	status = ydb_ci("usqroot", unum, uroot);
	if (status)
	{
		ydb_zstatus(&err[0], 500);
		PRINTF(" %s\n", err);
	}
	status = ydb_exit();
	if (status)
	{
		ydb_zstatus(&err[0], 500);
		PRINTF(" %s\n", err);
	}
	return 0;
}
